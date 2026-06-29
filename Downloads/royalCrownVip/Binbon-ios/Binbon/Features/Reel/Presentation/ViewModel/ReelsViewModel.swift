//
//  ReelsViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 25/05/2026.
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class ReelsViewModel: ObservableObject {
    
    enum ViewState {
        case idle
        case loading
        case loaded([ReelModel])
        case failed(APIError)
    }
    
    @Published private(set) var state: ViewState = .idle
    @Published var currentReelId: ReelModel.ID?
    @Published private(set) var progress: Double = 0
    @Published private(set) var isPaused: Bool = false
    @Published private(set) var isMuted: Bool = false
    @Published private(set) var likedReelIds: Set<ReelModel.ID> = []
    @Published private(set) var bookmarkedReelIds: Set<ReelModel.ID> = []
    
    // MARK: - Player
    private var players: [ReelModel.ID: AVPlayer] = [:]
    private var timeObserverToken: Any?
    private weak var observedPlayer: AVPlayer?
    private var isScrubbing = false
    private var wasPlayingBeforeScrub = false

    // Full-screen position preservation. A `fullScreenCover` over the paging
    // ScrollView makes it lose its position and snap to the first reel on
    // dismiss, so we pin the reel we opened from, ignore the transient scroll
    // callbacks fired while the cover is up, then ask the pager to scroll back
    // once the cover has fully dismissed.
    private var pinnedReelId: ReelModel.ID?
    private var isCoveredByFullScreen = false
    /// Reel the pager should scroll back to after a full-screen cover dismisses.
    @Published var restoreReelId: ReelModel.ID?

    // MARK: - Use cases
    private let fetchReelsUseCase: FetchReelsUseCase
    private let toggleLikeUseCase: ToggleReelLikeUseCase
    private let toggleBookmarkUseCase: ToggleReelBookmarkUseCase

    init(
        fetchReelsUseCase: FetchReelsUseCase,
        toggleLikeUseCase: ToggleReelLikeUseCase,
        toggleBookmarkUseCase: ToggleReelBookmarkUseCase
    ) {
        self.fetchReelsUseCase = fetchReelsUseCase
        self.toggleLikeUseCase = toggleLikeUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchReelsUseCase: container.makeFetchReelsUseCase(),
            toggleLikeUseCase: container.makeToggleReelLikeUseCase(),
            toggleBookmarkUseCase: container.makeToggleReelBookmarkUseCase()
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
                let reels = try await fetchReelsUseCase.execute()
                state = .loaded(reels)
                currentReelId = reels.first?.id

                if let first = reels.first {
                    _ = player(for: first)
                }

                attachObserver(to: currentReelId)
                playActive()
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }
    
    // MARK: - Player vending
    func player(for reel: ReelModel) -> AVPlayer {
        if let existing = players[reel.id] {
            return existing
        }
        let item = AVPlayerItem(url: reel.videoURL)
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
        
        players[reel.id] = player
        
        if reel.id == currentReelId {
            attachObserver(to: reel.id)
            player.play()
        }
        
        return player
    }
    
    // MARK: - Full screen
    /// Pins the active reel before a full-screen cover takes over.
    func enterFullScreen() {
        pinnedReelId = currentReelId
        isCoveredByFullScreen = true
    }

    /// Called once the cover has fully dismissed: stop ignoring scroll callbacks
    /// and ask the pager to scroll back to the reel we opened from.
    func exitFullScreen() {
        isCoveredByFullScreen = false
        restoreReelId = pinnedReelId
        pinnedReelId = nil
    }

    // MARK: - Active-reel lifecycle
    func activeReelChanged(to newID: ReelModel.ID?) {
        // The paging ScrollView fires spurious position changes while a
        // full-screen cover is up (it snaps to the first reel). Ignore them — the
        // pager restores the original reel once the cover dismisses.
        guard !isCoveredByFullScreen else { return }

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
        guard let id = currentReelId, let player = players[id] else { return }
        if isPaused {
            player.play()
            isPaused = false
        } else {
            player.pause()
            isPaused = true
        }
    }

    /// Pauses the active player WITHOUT marking the reel user-paused — used when
    /// the reels host leaves the screen (e.g. switching to another app tab).
    func suspend() {
        guard let id = currentReelId, let player = players[id] else { return }
        player.pause()
    }

    /// Resumes the active reel after returning, unless the user explicitly paused it.
    func resumeIfPlaying() {
        guard !isPaused else { return }
        playActive()
    }
    
    /// Mutes/unmutes audio across every loaded player so the choice persists as
    /// the user scrolls between reels (and applies to the active one immediately).
    func toggleMute() {
        isMuted.toggle()
        for player in players.values {
            player.isMuted = isMuted
        }
    }

    func skip(by seconds: Double) {
        guard
            let id = currentReelId,
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
    
    // MARK: - Likes
    
    func isLiked(_ reelID: ReelModel.ID) -> Bool {
        likedReelIds.contains(reelID)
    }
    
    /// Returns the count to display: original count + 1 if the user has liked this reel.
    func likeCount(for reel: ReelModel) -> Int {
        reel.likes + (likedReelIds.contains(reel.id) ? 1 : 0)
    }
    
    func toggleLike(for reelID: ReelModel.ID) {
        let willLike = !likedReelIds.contains(reelID)
        if willLike {
            likedReelIds.insert(reelID)
        } else {
            likedReelIds.remove(reelID)
        }
        Task { try? await toggleLikeUseCase.execute(reelID: reelID, liked: willLike) }
    }

    func likeFromDoubleTap(reelID: ReelModel.ID) {
        guard !likedReelIds.contains(reelID) else { return }
        likedReelIds.insert(reelID)
        Task { try? await toggleLikeUseCase.execute(reelID: reelID, liked: true) }
    }

    // MARK: - Bookmarks

    func isBookmarked(_ reelID: ReelModel.ID) -> Bool {
        bookmarkedReelIds.contains(reelID)
    }

    func toggleBookmark(for reelID: ReelModel.ID) {
        let willBookmark = !bookmarkedReelIds.contains(reelID)
        if willBookmark {
            bookmarkedReelIds.insert(reelID)
        } else {
            bookmarkedReelIds.remove(reelID)
        }
        Task { try? await toggleBookmarkUseCase.execute(reelID: reelID, bookmarked: willBookmark) }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }

    private func playActive() {
        guard let id = currentReelId, let player = players[id] else { return }
        player.seek(to: .zero)
        player.play()
    }
    
    // MARK: - Scrubbing
    func beginScrubbing() {
        guard let id = currentReelId, let player = players[id] else { return }
        isScrubbing = true
        
        wasPlayingBeforeScrub = !isPaused && player.rate != 0
        player.pause()
    }
    
    func scrub(to fraction: Double) {
        guard
            let id = currentReelId,
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
            let id = currentReelId,
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
    
    // MARK: - Progress observation
    private func attachObserver(to newID: ReelModel.ID?) {
        
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
