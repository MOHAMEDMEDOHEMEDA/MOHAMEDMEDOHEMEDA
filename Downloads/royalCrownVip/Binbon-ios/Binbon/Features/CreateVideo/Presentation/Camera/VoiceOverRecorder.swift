//
//  VoiceOverRecorder.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import Combine

final class VoiceOverRecorder: NSObject, ObservableObject {

    @Published private(set) var isRecording = false
    @Published private(set) var isPlaying = false
    @Published private(set) var fileURL: URL?
    @Published var volume: Float = 1.0 {
        didSet { player?.volume = volume }
    }

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    func toggle() { isRecording ? stop() : start() }

    func start() {
        stopPlayback()
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        guard recorder?.record() == true else { return }
        fileURL = url
        isRecording = true
    }

    func stop() {
        recorder?.stop()
        recorder = nil
        isRecording = false
        stopPlayback()
    }

    // MARK: - Playback

    func togglePlayback() { isPlaying ? stopPlayback() : play() }

    func play() {
        guard let fileURL else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: fileURL)
        player?.delegate = self
        player?.volume = volume
        guard player?.play() == true else { return }
        isPlaying = true
    }

    func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    func loadExisting(_ url: URL?, volume: Float) {
        guard !isRecording else { return }
        fileURL = url
        self.volume = volume
    }

    func clear() {
        stop()
        fileURL = nil
    }
}

extension VoiceOverRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        isPlaying = false
    }
}
