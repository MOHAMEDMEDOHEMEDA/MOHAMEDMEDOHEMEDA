//
//  ShortsViewModel.swift
//  Binbon
//
//  Drives the Shorts feed: vends an AVPlayer per short, tracks the active short,
//  playback progress, mute and like state. A trimmed sibling of ReelsViewModel —
//  shorts only expose mute + like, no bookmark/full-screen.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class ShortsViewModel: ObservableObject {

    enum ViewState {
        case idle
        case loading
        case loaded([ShortModel])
        case failed(APIError)
    }

    @Published private(set) var state: ViewState = .idle
    @Published var currentShortId: ShortModel.ID?
    @Published private(set) var progress: Double = 0
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var likedShortIds: Set<ShortModel.ID> = []

    private var players: [ShortModel.ID: AVPlayer] = [:]
    private var timeObserverToken: Any?
    private weak var observedPlayer: AVPlayer?
    private var isScrubbing = false
    private var wasPlayingBeforeScrub = false

    private let fetchShortsUseCase: FetchShortsUseCase
    private let toggleLikeUseCase: ToggleShortLikeUseCase

    init(
        fetchShortsUseCase: FetchShortsUseCase,
        toggleLikeUseCase: ToggleShortLikeUseCase
    ) {
        self.fetchShortsUseCase = fetchShortsUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchShortsUseCase: container.makeFetchShortsUseCase(),
            toggleLikeUseCase: container.makeToggleShortLikeUseCase()
        )
    }

    deinit {
        if let token = timeObserverToken {
            observedPlayer?.removeTimeObserver(token)
        }
    }

    // MARK: - Loading

    func load() {
        Task {
            state = .loading
            do {
                let shorts = try await fetchShortsUseCase.execute()
                state = .loaded(shorts)
                currentShortId = shorts.first?.id
                if let first = shorts.first { _ = player(for: first) }
                attachObserver(to: currentShortId)
                playActive()
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    // MARK: - Player vending

    func player(for short: ShortModel) -> AVPlayer {
        if let existing = players[short.id] { return existing }

        let item = AVPlayerItem(url: short.videoURL)
        let player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .none
        player.isMuted = isMuted

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        players[short.id] = player

        if short.id == currentShortId {
            attachObserver(to: short.id)
            player.play()
        }
        return player
    }

    // MARK: - Active-short lifecycle

    func activeShortChanged(to newID: ShortModel.ID?) {
        for (id, player) in players where id != newID {
            player.pause()
        }
        isPaused = false
        isScrubbing = false
        progress = 0
        attachObserver(to: newID)
        playActive()
    }

    func togglePlayPause() {
        guard let id = currentShortId, let player = players[id] else { return }
        if isPaused {
            player.play()
            isPaused = false
        } else {
            player.pause()
            isPaused = true
        }
    }

    /// Pauses the active player without marking the short user-paused — used when
    /// the host leaves the screen (e.g. paging to another home tab).
    func suspend() {
        guard let id = currentShortId, let player = players[id] else { return }
        player.pause()
    }

    /// Resumes the active short after returning, unless the user explicitly paused it.
    func resumeIfPlaying() {
        guard !isPaused else { return }
        playActive()
    }

    func toggleMute() {
        isMuted.toggle()
        for player in players.values {
            player.isMuted = isMuted
        }
    }

    // MARK: - Likes

    func isLiked(_ shortID: ShortModel.ID) -> Bool {
        likedShortIds.contains(shortID)
    }

    func toggleLike(for shortID: ShortModel.ID) {
        let willLike = !likedShortIds.contains(shortID)
        if willLike {
            likedShortIds.insert(shortID)
        } else {
            likedShortIds.remove(shortID)
        }
        Task { try? await toggleLikeUseCase.execute(shortID: shortID, liked: willLike) }
    }

    /// Double-tap only likes (never unlikes), matching the reels behaviour.
    func likeFromDoubleTap(shortID: ShortModel.ID) {
        guard !likedShortIds.contains(shortID) else { return }
        likedShortIds.insert(shortID)
        Task { try? await toggleLikeUseCase.execute(shortID: shortID, liked: true) }
    }

    // MARK: - Scrubbing

    func beginScrubbing() {
        guard let id = currentShortId, let player = players[id] else { return }
        isScrubbing = true
        wasPlayingBeforeScrub = !isPaused && player.rate != 0
        player.pause()
    }

    func scrub(to fraction: Double) {
        guard let id = currentShortId, let player = players[id],
              let item = player.currentItem, item.duration.isNumeric, item.duration.seconds > 0
        else { return }
        progress = max(0, min(1, fraction))
        let target = progress * item.duration.seconds
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600),
                    toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
    }

    func endScrubbing(at fraction: Double) {
        guard let id = currentShortId, let player = players[id],
              let item = player.currentItem, item.duration.isNumeric, item.duration.seconds > 0
        else { isScrubbing = false; return }

        progress = max(0, min(1, fraction))
        let target = progress * item.duration.seconds
        player.seek(to: CMTime(seconds: target, preferredTimescale: 600),
                    toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
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

    // MARK: - Helpers

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }

    private func playActive() {
        guard let id = currentShortId, let player = players[id] else { return }
        player.seek(to: .zero)
        player.play()
    }

    private func attachObserver(to newID: ShortModel.ID?) {
        if let token = timeObserverToken, let prev = observedPlayer {
            prev.removeTimeObserver(token)
        }
        timeObserverToken = nil
        observedPlayer = nil

        guard let id = newID, let player = players[id] else { return }

        let interval = CMTime(seconds: 1.0 / 30.0, preferredTimescale: 600)
        let token = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor [weak self] in
                guard let self, !self.isScrubbing else { return }
                guard let item = player.currentItem, item.duration.isNumeric, item.duration.seconds > 0 else {
                    self.progress = 0
                    return
                }
                self.progress = time.seconds / item.duration.seconds
            }
        }
        timeObserverToken = token
        observedPlayer = player
    }
}

private extension CMTime {
    var isNumeric: Bool { flags.contains(.valid) && !flags.contains(.indefinite) }
}
