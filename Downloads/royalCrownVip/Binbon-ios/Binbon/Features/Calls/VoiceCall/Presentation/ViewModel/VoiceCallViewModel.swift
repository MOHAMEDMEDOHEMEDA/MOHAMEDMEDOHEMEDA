//
//  VoiceCallViewModel.swift
//  Binbon
//

import SwiftUI
import Combine

/// Owns the live state of a voice call — media toggles, the participant roster,
/// moderation flags, the call timer and the local raise-hand / reaction state.
/// The view keeps only ephemeral UI state (open sheets, menu anchors).
@MainActor
final class VoiceCallViewModel: ObservableObject {

    @Published private(set) var session: VoiceCallSession?

    // Local media
    @Published var isSpeakerMuted = true
    @Published var isVideoEnabled = false
    @Published var isMicEnabled = true

    // Owner / moderation
    @Published var isAllSoundMuted = false
    @Published var isAllRestricted = false
    @Published var isScreenSharing = false

    // Local presence
    @Published var localIsRaisedHand = false
    @Published var localActiveReaction: String?

    @Published private(set) var addedParticipants: [CallParticipant] = [] {
        didSet { syncTimer() }
    }
    @Published private(set) var elapsedSeconds = 0

    private let loadVoiceCallSessionUseCase: LoadVoiceCallSessionUseCase
    private var loadedKey: String?
    private var timerTask: Task<Void, Never>?
    private var reactionDismissTask: Task<Void, Never>?
    private var raiseHandDismissTask: Task<Void, Never>?

    private let maxParticipants = 50

    /// Identity used before the session resolves, so participant keys stay stable.
    private var fallbackParticipant = CallParticipant(name: "")

    var transitionsToVideo: Bool { session?.transitionsToVideo ?? false }

    var primaryParticipant: CallParticipant {
        session?.primaryParticipant ?? fallbackParticipant
    }

    var isGroupCall: Bool { !addedParticipants.isEmpty }

    /// The owner's tile — name suffixed with "(me)" and carrying the local
    /// raise-hand / reaction so it animates alongside the remote tiles.
    var localParticipant: CallParticipant {
        var p = CallParticipant(
            id: primaryParticipant.id,
            name: primaryParticipant.name + " (" + "voice_call_me".localized + ")",
            avatarURL: primaryParticipant.avatarURL,
            avatarAsset: primaryParticipant.avatarAsset,
            isOwner: true
        )
        p.isRaisedHand = localIsRaisedHand
        p.activeReaction = localActiveReaction
        return p
    }

    var allParticipants: [CallParticipant] {
        [localParticipant] + addedParticipants
    }

    var excludedContactIDs: Set<UUID> {
        Set([primaryParticipant.id] + addedParticipants.map(\.id))
    }

    var durationText: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
            : String(format: "%02d:%02d", minutes, seconds)
    }

    init(loadVoiceCallSessionUseCase: LoadVoiceCallSessionUseCase) {
        self.loadVoiceCallSessionUseCase = loadVoiceCallSessionUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(loadVoiceCallSessionUseCase: container.makeLoadVoiceCallSessionUseCase())
    }

    deinit {
        timerTask?.cancel()
        reactionDismissTask?.cancel()
        raiseHandDismissTask?.cancel()
    }

    func load(contactName: String, avatarURL: String?, avatarAsset: String, transitionsToVideo: Bool) async {
        let key = "\(contactName)|\(avatarURL ?? "")|\(avatarAsset)|\(transitionsToVideo)"
        guard loadedKey != key else { return }
        loadedKey = key

        fallbackParticipant = CallParticipant(name: contactName, avatarURL: avatarURL, avatarAsset: avatarAsset)

        do {
            session = try await loadVoiceCallSessionUseCase.execute(
                contactName: contactName,
                avatarURL: avatarURL,
                avatarAsset: avatarAsset,
                transitionsToVideo: transitionsToVideo
            )
        } catch {
            session = VoiceCallSession(primaryParticipant: fallbackParticipant, transitionsToVideo: transitionsToVideo)
        }
    }

    // MARK: - Media toggles

    func toggleSpeaker() { isSpeakerMuted.toggle() }

    func toggleVideo() { isVideoEnabled.toggle() }

    func toggleMicrophone() {
        isMicEnabled.toggle()
        if isMicEnabled && isAllSoundMuted {
            isAllSoundMuted = false
        }
    }

    // MARK: - Roster

    func addParticipant(_ contact: MessageConversation) {
        guard allParticipants.count < maxParticipants else { return }
        let participant = CallParticipant(conversation: contact)
        guard participant.name != primaryParticipant.name else { return }
        guard !addedParticipants.contains(participant) else { return }
        addedParticipants.append(participant)
    }

    func isParticipantMuted(_ id: UUID) -> Bool {
        addedParticipants.first { $0.id == id }?.isMuted ?? false
    }

    func toggleParticipantMute(_ id: UUID) {
        guard let idx = addedParticipants.firstIndex(where: { $0.id == id }) else { return }
        addedParticipants[idx].isMuted.toggle()
        if !addedParticipants[idx].isMuted && isAllSoundMuted {
            isAllSoundMuted = false
        }
    }

    // MARK: - Owner actions

    func toggleMuteAll() {
        isAllSoundMuted.toggle()
        for i in addedParticipants.indices {
            addedParticipants[i].isMuted = isAllSoundMuted
        }
    }

    func muteAllExceptOwner() {
        for i in addedParticipants.indices {
            addedParticipants[i].isMuted = true
        }
        isAllSoundMuted = true
    }

    // MARK: - Presence

    func toggleRaiseHand() {
        raiseHandDismissTask?.cancel()
        localIsRaisedHand.toggle()
        guard localIsRaisedHand else { return }
        raiseHandDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) { self?.localIsRaisedHand = false }
            }
        }
    }

    func sendReaction(_ emoji: String) {
        localActiveReaction = emoji
        reactionDismissTask?.cancel()
        reactionDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) { self?.localActiveReaction = nil }
            }
        }
    }

    // MARK: - Timer

    /// The call timer only runs once the call becomes a group; a one-to-one call
    /// shows "calling…" instead of an elapsed time.
    private func syncTimer() {
        timerTask?.cancel()
        guard isGroupCall else {
            elapsedSeconds = 0
            return
        }
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run { self?.elapsedSeconds += 1 }
            }
        }
    }
}
