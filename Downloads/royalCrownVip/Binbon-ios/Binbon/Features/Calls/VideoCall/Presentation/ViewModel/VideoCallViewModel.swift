//
//  VideoCallViewModel.swift
//  Binbon
//

import Foundation
import Combine

@MainActor
final class VideoCallViewModel: ObservableObject {

    @Published private(set) var session: VideoCallSession?
    @Published var isSpeakerEnabled = true
    @Published var isVideoEnabled = true
    @Published var isMicEnabled = true
    @Published private(set) var contacts: [CallContact] = CallContact.mockList
    @Published private(set) var elapsedSeconds: Int = 0

    /// Participants whose video the local user has turned off — their tile collapses
    /// to a blurred avatar.
    @Published private(set) var videoOffParticipantIDs: Set<String> = []
    /// Participants the local user has muted.
    @Published var mutedParticipantIDs: Set<String> = []
    @Published var localIsRaisedHand = false
    @Published var localActiveReaction: String? = nil

    private var reactionDismissTask: Task<Void, Never>?
    private var raiseHandDismissTask: Task<Void, Never>?

    private let loadVideoCallSessionUseCase: LoadVideoCallSessionUseCase
    private var loadedKey: String?
    private var timerTask: Task<Void, Never>?

    var durationText: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }

    init(loadVideoCallSessionUseCase: LoadVideoCallSessionUseCase) {
        self.loadVideoCallSessionUseCase = loadVideoCallSessionUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(loadVideoCallSessionUseCase: container.makeLoadVideoCallSessionUseCase())
    }

    func load(contactName: String, avatarURL: String?) async {
        let key = "\(contactName)|\(avatarURL ?? "")"
        guard loadedKey != key else { return }
        loadedKey = key

        do {
            session = try await loadVideoCallSessionUseCase.execute(contactName: contactName, avatarURL: avatarURL)
        } catch {
            session = nil
        }

        startTimer()
    }

    private func startTimer() {
        timerTask?.cancel()
        elapsedSeconds = 0
        timerTask = Task.detached(priority: .utility) { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run { [weak self] in
                    self?.elapsedSeconds += 1
                }
            }
        }
    }

    deinit {
        timerTask?.cancel()
    }

    func toggleSpeaker() {
        isSpeakerEnabled.toggle()
    }

    func toggleVideo() {
        isVideoEnabled.toggle()
    }

    func toggleMicrophone() {
        isMicEnabled.toggle()
    }

    func isVideoOff(_ participantID: String) -> Bool {
        videoOffParticipantIDs.contains(participantID)
    }

    func isMuted(_ participantID: String) -> Bool {
        mutedParticipantIDs.contains(participantID)
    }

    func toggleParticipantVideo(_ participantID: String) {
        if videoOffParticipantIDs.contains(participantID) {
            videoOffParticipantIDs.remove(participantID)
        } else {
            videoOffParticipantIDs.insert(participantID)
        }
    }

    func toggleParticipantMute(_ participantID: String) {
        if mutedParticipantIDs.contains(participantID) {
            mutedParticipantIDs.remove(participantID)
        } else {
            mutedParticipantIDs.insert(participantID)
        }
    }

    func toggleRaiseHand() {
        raiseHandDismissTask?.cancel()
        localIsRaisedHand.toggle()
        if localIsRaisedHand {
            raiseHandDismissTask = Task {
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled else { return }
                localIsRaisedHand = false
            }
        }
    }

    func sendReaction(_ emoji: String) {
        localActiveReaction = emoji
        reactionDismissTask?.cancel()
        reactionDismissTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            localActiveReaction = nil
        }
    }

    // Mock phase: restriction / block / report are not yet wired to the backend.
    func restrictParticipant(_ participantID: String) {}
    func blockParticipant(_ participantID: String) {}
    func reportParticipant(_ participantID: String) {}

    func addParticipant(_ contact: CallContact) {
        // Tiles are keyed by participant id for the action-menu anchor; a duplicate
        // id would collide and break the menu on the older tile, so ignore re-adds.
        guard !(session?.participants.contains { $0.id == contact.id } ?? false) else { return }

        let newParticipant = VideoCallParticipant(
            id: contact.id,
            name: contact.displayName,
            imageAsset: "call-remote-video",
            avatarURL: contact.avatarURL,
            accent: .remote
        )
        if session != nil {
            session = VideoCallSession(
                durationText: session!.durationText,
                participants: session!.participants + [newParticipant]
            )
        } else {
            session = VideoCallSession(durationText: "00:00", participants: [newParticipant])
        }
    }
}
