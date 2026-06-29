//
//  VideoAudioMixer.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation

enum VideoAudioMixer {

    static func mix(videoURL: URL,
                    originalVolume: Float,
                    soundFileName: String?,
                    soundVolume: Float,
                    voiceoverURL: URL?,
                    voiceoverVolume: Float = 1.0) async -> URL {
        do {
            return try await bake(videoURL: videoURL,
                                  originalVolume: originalVolume,
                                  soundFileName: soundFileName,
                                  soundVolume: soundVolume,
                                  voiceoverURL: voiceoverURL,
                                  voiceoverVolume: voiceoverVolume)
        } catch {
            return videoURL
        }
    }

    private static func bake(videoURL: URL,
                             originalVolume: Float,
                             soundFileName: String?,
                             soundVolume: Float,
                             voiceoverURL: URL?,
                             voiceoverVolume: Float) async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        let duration = try await asset.load(.duration)
        let fullRange = CMTimeRange(start: .zero, duration: duration)

        let composition = AVMutableComposition()
        var params: [AVMutableAudioMixInputParameters] = []

        if let v = try await asset.loadTracks(withMediaType: .video).first {
            let track = composition.addMutableTrack(withMediaType: .video,
                                                    preferredTrackID: kCMPersistentTrackID_Invalid)
            try track?.insertTimeRange(fullRange, of: v, at: .zero)
            track?.preferredTransform = try await v.load(.preferredTransform)
        }

        if originalVolume > 0, let a = try await asset.loadTracks(withMediaType: .audio).first {
            if let track = composition.addMutableTrack(withMediaType: .audio,
                                                       preferredTrackID: kCMPersistentTrackID_Invalid) {
                try? track.insertTimeRange(fullRange, of: a, at: .zero)
                params.append(volumeParams(track, originalVolume))
            }
        }

        if soundVolume > 0, let name = soundFileName, let url = resolveSound(name) {
            let soundAsset = AVURLAsset(url: url)
            if let sa = try? await soundAsset.loadTracks(withMediaType: .audio).first,
               let soundDuration = try? await soundAsset.load(.duration), soundDuration.seconds > 0,
               let track = composition.addMutableTrack(withMediaType: .audio,
                                                       preferredTrackID: kCMPersistentTrackID_Invalid) {
                var cursor = CMTime.zero
                while cursor < duration {
                    let chunk = min(soundDuration, duration - cursor)
                    try? track.insertTimeRange(CMTimeRange(start: .zero, duration: chunk), of: sa, at: cursor)
                    cursor = CMTimeAdd(cursor, chunk)
                }
                params.append(volumeParams(track, soundVolume))
            }
        }

        if voiceoverVolume > 0, let voiceoverURL {
            let voAsset = AVURLAsset(url: voiceoverURL)
            if let voa = try? await voAsset.loadTracks(withMediaType: .audio).first,
               let voDuration = try? await voAsset.load(.duration), voDuration.seconds > 0,
               let track = composition.addMutableTrack(withMediaType: .audio,
                                                       preferredTrackID: kCMPersistentTrackID_Invalid) {
                let insert = min(voDuration, duration)
                try? track.insertTimeRange(CMTimeRange(start: .zero, duration: insert), of: voa, at: .zero)
                params.append(volumeParams(track, voiceoverVolume))
            }
        }

        guard let export = AVAssetExportSession(asset: composition,
                                                presetName: AVAssetExportPresetHighestQuality) else { return videoURL }
        if !params.isEmpty {
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = params
            export.audioMix = audioMix
        }
        let outURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        export.outputURL = outURL
        export.outputFileType = .mov

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            export.exportAsynchronously { c.resume() }
        }
        return export.status == .completed ? outURL : videoURL
    }

    private static func volumeParams(_ track: AVCompositionTrack, _ volume: Float) -> AVMutableAudioMixInputParameters {
        let p = AVMutableAudioMixInputParameters(track: track)
        p.setVolume(volume, at: .zero)
        return p
    }

    private static func resolveSound(_ name: String) -> URL? {
        for ext in ["mp3", "m4a", "aac", "wav"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) { return url }
        }
        return nil
    }
}
