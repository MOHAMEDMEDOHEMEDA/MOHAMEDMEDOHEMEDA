//
//  LoopingPlayer.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import Combine
import SwiftUI

struct LoopingPlayer: UIViewRepresentable {

    let url: URL
    var volume: Float = 1.0

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.configure(with: url, volume: volume)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.configure(with: url, volume: volume)
    }

    final class PlayerView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

        private var looper: AVPlayerLooper?
        private var queuePlayer: AVQueuePlayer?
        private var currentURL: URL?

        func configure(with url: URL, volume: Float) {
            if currentURL != url {
                currentURL = url
                let item = AVPlayerItem(url: url)
                let player = AVQueuePlayer(playerItem: item)
                looper = AVPlayerLooper(player: player, templateItem: item)
                queuePlayer = player
                playerLayer.player = player
                playerLayer.videoGravity = .resizeAspectFill
                player.play()
            }
            queuePlayer?.volume = volume
            queuePlayer?.isMuted = volume <= 0
            if queuePlayer?.timeControlStatus != .playing { queuePlayer?.play() }
        }
    }
}

final class ClipPreviewPlayer: ObservableObject {

    let player = AVQueuePlayer()
    private var looper: AVPlayerLooper?
    private var currentURL: URL?

    init() {
        player.automaticallyWaitsToMinimizeStalling = false
    }

    func load(_ url: URL?) {
        guard let url else { return }
        if currentURL != url {
            currentURL = url
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: player, templateItem: item)
        }
        play()
    }

    func setVolume(_ volume: Float) {
        player.volume = volume
        player.isMuted = volume <= 0
    }

    func play() { player.playImmediately(atRate: 1.0) }
    func stop() { player.pause() }
}

struct PlayerLayerView: UIViewRepresentable {

    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.player = player
        if player.timeControlStatus != .playing { player.play() }
    }

    final class PlayerView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}
