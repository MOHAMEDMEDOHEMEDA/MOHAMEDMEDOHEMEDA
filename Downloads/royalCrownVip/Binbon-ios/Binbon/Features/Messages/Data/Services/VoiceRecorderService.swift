//
//  VoiceRecorderService.swift
//  Binbon
//

import AVFoundation
import Foundation

/// Thin wrapper around AVAudioRecorder. Handles hardware only — state is owned by ChatViewModel.
final class VoiceRecorderService {

    private var recorder: AVAudioRecorder?
    private(set) var currentURL: URL?

    // MARK: Permission

    func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    // MARK: Record

    @discardableResult
    func startRecording() -> Bool {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default,
                                 options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")
        currentURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        guard let r = try? AVAudioRecorder(url: url, settings: settings) else { return false }
        r.isMeteringEnabled = true
        r.prepareToRecord()
        r.record()
        recorder = r
        return true
    }

    func pause() { recorder?.pause() }
    func resume() { recorder?.record() }

    func stop() -> URL? {
        recorder?.stop()
        let url = currentURL
        recorder = nil
        currentURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        return url
    }

    func cancel() {
        let url = currentURL
        stop()
        if let url { try? FileManager.default.removeItem(at: url) }
    }

    // MARK: Metering

    /// Returns normalized amplitude [0…1]. Call from a metering timer.
    func sampleAmplitude() -> CGFloat {
        guard let r = recorder else { return 0 }
        r.updateMeters()
        let power = r.averagePower(forChannel: 0) // dBFS, typically -160…0
        return CGFloat(max(0, min(1, (power + 50) / 50)))
    }
}
