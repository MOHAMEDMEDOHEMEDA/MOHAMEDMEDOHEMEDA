//
//  VideoEffectsProcessor.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

enum VideoEffectsProcessor {

    enum ProcessingError: Error { case noVideoTrack, exportFailed }

    static func process(url: URL,
                        filter: VideoFilter,
                        effect: VideoEffect,
                        beauty: Bool,
                        speed: VideoSpeed) async -> URL {
        do {
            return try await bake(url: url, filter: filter, effect: effect, beauty: beauty, speed: speed)
        } catch {
            return url
        }
    }

    private static func bake(url: URL,
                             filter: VideoFilter,
                             effect: VideoEffect,
                             beauty: Bool,
                             speed: VideoSpeed) async throws -> URL {
        let asset = AVURLAsset(url: url)
        let duration = try await asset.load(.duration)

        guard let srcVideo = try await asset.loadTracks(withMediaType: .video).first else {
            throw ProcessingError.noVideoTrack
        }

        let composition = AVMutableComposition()
        let fullRange = CMTimeRange(start: .zero, duration: duration)

        let videoTrack = composition.addMutableTrack(withMediaType: .video,
                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        try videoTrack?.insertTimeRange(fullRange, of: srcVideo, at: .zero)
        videoTrack?.preferredTransform = try await srcVideo.load(.preferredTransform)

        if let srcAudio = try await asset.loadTracks(withMediaType: .audio).first {
            let audioTrack = composition.addMutableTrack(withMediaType: .audio,
                                                         preferredTrackID: kCMPersistentTrackID_Invalid)
            try? audioTrack?.insertTimeRange(fullRange, of: srcAudio, at: .zero)
        }

        if speed != .normal {
            let scaledDuration = CMTimeMultiplyByFloat64(duration, multiplier: 1.0 / speed.rawValue)
            composition.scaleTimeRange(fullRange, toDuration: scaledDuration)
        }

        guard let export = AVAssetExportSession(asset: composition,
                                                presetName: AVAssetExportPresetHighestQuality) else {
            throw ProcessingError.exportFailed
        }

        if filter != .none || effect != .none || beauty {
            export.videoComposition = AVMutableVideoComposition(asset: composition) { request in
                var image = request.sourceImage.clampedToExtent()
                image = filter.apply(to: image)
                image = effect.apply(to: image)
                if beauty { image = beautify(image) }
                request.finish(with: image.cropped(to: request.sourceImage.extent), context: nil)
            }
        }

        let outURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        export.outputURL = outURL
        export.outputFileType = .mov
        export.shouldOptimizeForNetworkUse = true

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            export.exportAsynchronously { continuation.resume() }
        }

        guard export.status == .completed else {
            throw export.error ?? ProcessingError.exportFailed
        }
        return outURL
    }

    private static func beautify(_ image: CIImage) -> CIImage {
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = 2.2
        let blurred = (blur.outputImage ?? image).cropped(to: image.extent)

        let mix = CIFilter.dissolveTransition()
        mix.inputImage = image
        mix.targetImage = blurred
        mix.time = 0.45
        let softened = mix.outputImage ?? image

        let highlight = CIFilter.highlightShadowAdjust()
        highlight.inputImage = softened
        highlight.highlightAmount = 1.0
        highlight.shadowAmount = 0.25
        return highlight.outputImage ?? softened
    }
}
