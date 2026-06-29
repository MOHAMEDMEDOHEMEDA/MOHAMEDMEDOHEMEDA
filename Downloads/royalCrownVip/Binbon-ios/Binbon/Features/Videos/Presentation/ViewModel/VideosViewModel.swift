//
//  ReelsViewModel.swift
//  Binbon
//
//  Created by Mostafa Sobaih on 04/06/2026.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class VideosViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case loaded([VideoModel])
        case failed(String)
    }

    @Published private(set) var state: ViewState = .idle
    @Published var currentVideoId: String?
    @Published private(set) var progress: Double = 0
    @Published private(set) var currentTimeText: String = "00:00"
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var playbackRate: Float = 1.0

    private var players: [String: AVPlayer] = [:]
    private var timeObserverToken: Any?
    private weak var observedPlayer: AVPlayer?
    private var isScrubbing = false
    private var wasPlayingBeforeScrub = false

    // MARK: - Use cases
    private let fetchVideosFeedUseCase: FetchVideosFeedUseCase

    init(fetchVideosFeedUseCase: FetchVideosFeedUseCase) {
        self.fetchVideosFeedUseCase = fetchVideosFeedUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(fetchVideosFeedUseCase: container.makeFetchVideosFeedUseCase())
    }

    deinit {
        if let token = timeObserverToken {
            observedPlayer?.removeTimeObserver(token)
        }
    }

    func load() {
        Task {
            state = .loading
            do {
                let videos = try await fetchVideosFeedUseCase.execute()
                state = .loaded(videos)
            } catch {
                state = .failed(error.localizedDescription)
            }
        }
    }

    func activateVideo(_ id: String, autoplay: Bool = true) {
        guard currentVideoId != id else {
            return
        }

        currentVideoId = id
        isPaused = !autoplay
        activeVideoChanged(to: id, autoplay: autoplay)
    }

    func player(for video: VideoModel) -> AVPlayer? {
        guard let url = video.videoURL else { return nil }
        if let existing = players[video.id] {
            return existing
        }

        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .none
        player.isMuted = isMuted

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak player, weak self] _ in
            player?.pause()
            self?.isPaused = true
        }

        players[video.id] = player

        if video.id == currentVideoId {
            attachObserver(to: video.id)
            player.play()
        }

        return player
    }

    func togglePlayPause() {
        guard let id = currentVideoId, let player = players[id] else { return }
        if isPaused {
            // If video has ended (progress near 1.0), restart from beginning
            if progress >= 0.99 {
                player.seek(to: .zero)
            }
            player.play()
            player.rate = playbackRate
            isPaused = false
        } else {
            player.pause()
            isPaused = true
        }
    }

    func toggleMute() {
        guard let id = currentVideoId, let player = players[id] else { return }
        player.isMuted.toggle()
        isMuted = player.isMuted
    }

    /// Sets the playback speed of the active player (applied immediately when playing).
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        guard let id = currentVideoId, let player = players[id] else { return }
        if !isPaused { player.rate = rate }
    }

    func skip(by seconds: Double) {
        guard
            let id = currentVideoId,
            let player = players[id],
            let item = player.currentItem,
            item.duration.isNumeric,
            item.duration.seconds > 0
        else { return }

        let current = player.currentTime().seconds
        let duration = item.duration.seconds
        let target = max(0, min(duration, current + seconds))
        let time = CMTime(seconds: target, preferredTimescale: 600)

        progress = target / duration
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func beginScrubbing() {
        guard let id = currentVideoId, let player = players[id] else { return }
        isScrubbing = true
        wasPlayingBeforeScrub = !isPaused && player.rate != 0
        player.pause()
    }

    func scrub(to fraction: Double) {
        guard
            let id = currentVideoId,
            let player = players[id],
            let item = player.currentItem,
            item.duration.isNumeric,
            item.duration.seconds > 0
        else { return }

        progress = max(0, min(1, fraction))
        let targetSeconds = progress * item.duration.seconds
        let time = CMTime(seconds: targetSeconds, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
    }

    func endScrubbing(at fraction: Double) {
        guard
            let id = currentVideoId,
            let player = players[id],
            let item = player.currentItem,
            item.duration.isNumeric,
            item.duration.seconds > 0
        else {
            isScrubbing = false
            return
        }

        progress = max(0, min(1, fraction))
        let targetSeconds = progress * item.duration.seconds
        let time = CMTime(seconds: targetSeconds, preferredTimescale: 600)

        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isScrubbing = false
                if self.wasPlayingBeforeScrub {
                    player.play()
                    self.isPaused = false
                }
            }
        }
    }

    private func activeVideoChanged(to newID: String?, autoplay: Bool = true) {
        for (id, player) in players where id != newID {
            player.pause()
        }
        isPaused = !autoplay
        isScrubbing = false
        progress = 0
        attachObserver(to: newID)
        if autoplay {
            playActive()
        } else if let id = newID, let player = players[id] {
            player.pause()
            player.seek(to: .zero)
            isMuted = player.isMuted
        }
    }

    private func playActive() {
        guard let id = currentVideoId, let player = players[id] else { return }
        player.seek(to: .zero)
        player.play()
        player.rate = playbackRate
        isMuted = player.isMuted
    }

    private func attachObserver(to newID: String?) {
        if let token = timeObserverToken, let prev = observedPlayer {
            prev.removeTimeObserver(token)
        }
        timeObserverToken = nil
        observedPlayer = nil

        guard let id = newID, let player = players[id] else { return }

        let interval = CMTime(seconds: 1.0 / 30.0, preferredTimescale: 600)
        let token = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard !self.isScrubbing else { return }
                guard
                    let item = player.currentItem,
                    item.duration.isNumeric,
                    item.duration.seconds > 0
                else {
                    self.progress = 0
                    self.currentTimeText = "00:00"
                    return
                }
                self.progress = time.seconds / item.duration.seconds
                self.currentTimeText = self.formatTime(time.seconds)
            }
        }
        timeObserverToken = token
        observedPlayer = player
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "00:00" }
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private extension CMTime {
    var isNumeric: Bool { flags.contains(.valid) && !flags.contains(.indefinite) }
}
