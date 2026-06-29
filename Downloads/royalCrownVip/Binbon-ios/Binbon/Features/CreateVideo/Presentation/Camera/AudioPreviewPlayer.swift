//
//  AudioPreviewPlayer.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import Combine

final class AudioPreviewPlayer: ObservableObject {

    @Published private(set) var playingFileName: String?

    private var player: AVAudioPlayer?

    func play(fileName: String?, volume: Float = 1.0, mixWithCapture: Bool = true) {
        stop()
        guard let fileName, let url = Self.resolve(fileName) else { return }
        if mixWithCapture {
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                             options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth])
        } else {
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        }
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.volume = volume
        player?.play()
        playingFileName = fileName
    }

    func setVolume(_ volume: Float) { player?.volume = volume }

    func stop() {
        player?.stop()
        player = nil
        playingFileName = nil
    }

    private static func resolve(_ name: String) -> URL? {
        for ext in ["mp3", "m4a", "aac", "wav"] {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) { return url }
        }
        return nil
    }
}
