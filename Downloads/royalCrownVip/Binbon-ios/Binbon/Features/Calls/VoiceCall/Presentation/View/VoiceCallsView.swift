//
//  VoiceCallsView.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 23/06/2026.
//

import SwiftUI

/// Composition root for the voice-call screen. The live call state lives in
/// `VoiceCallViewModel`; this view wires the section components together and owns only
/// ephemeral UI state (open sheets, popover anchors) and the more-options popovers whose
/// positioning depends on the full-screen geometry.
struct VoiceCallsView: View {

    // MARK: - Inputs

    let contactName: String
    let avatarURL: String?
    let avatarAsset: String
    let transitionsToVideo: Bool

    @Environment(\.router) private var router
    @StateObject private var viewModel: VoiceCallViewModel

    // MARK: - Ephemeral UI state

    @State private var showMoreOptions = false
    @State private var showMeetingMenu = false
    @State private var showBlockSheet = false
    @State private var showReportSheet = false
    @State private var showAddPersonSheet = false
    @State private var showExpandedControls = false
    @State private var showEmojiReactions = false
    @State private var isOpenMeetingEnabled = true
    @State private var isRemoteSoundMuted = false
    @State private var isRemoteRestricted = false
    @State private var ringTask: Task<Void, Never>?

    /// Anchor of the currently open participant menu and the per-tile button frames it
    /// is positioned against (collected from the grid in the `voiceCallBody` space).
    @State private var menuParticipantID: UUID?
    @State private var menuAnchorFrame: CGRect = .zero
    @State private var tileButtonFrames: [UUID: CGRect] = [:]

    /// Reserved so caller content stays put; the menu expands without shifting layout.
    private let collapsedControlsReservedHeight: CGFloat = 140
    private let maxInlineParticipants = 10

    @MainActor
    init(
        contactName: String = "voice_call_mock_contact".localized,
        avatarURL: String? = nil,
        avatarAsset: String = "call-image",
        transitionsToVideo: Bool = false,
        viewModel: VoiceCallViewModel? = nil
    ) {
        self.contactName = contactName
        self.avatarURL = avatarURL
        self.avatarAsset = avatarAsset
        self.transitionsToVideo = transitionsToVideo
        _viewModel = StateObject(wrappedValue: viewModel ?? VoiceCallViewModel())
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if viewModel.isGroupCall {
                Color.black.ignoresSafeArea()
            } else {
                VoiceCallBackground(avatarURL: avatarURL, avatarAsset: avatarAsset)
            }

            VStack(spacing: 0) {
                VoiceCallTopBar(
                    isGroupCall: viewModel.isGroupCall,
                    durationText: viewModel.durationText,
                    onMenu: { showMoreOptions = false; showMeetingMenu.toggle() },
                    onAddPerson: { showAddPersonSheet = true },
                    onMore: {
                        showMeetingMenu = false
                        withAnimation(.easeOut(duration: 0.15)) { showMoreOptions.toggle() }
                    },
                    onMinimize: { router.back() }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)

                participantsArea
                    .padding(.horizontal, viewModel.isGroupCall ? 12 : 24)
                    .padding(.top, viewModel.isGroupCall ? 10 : 0)
                    .frame(maxHeight: .infinity)
                    .onPreferenceChange(TileButtonFrameKey.self) { frames in
                        tileButtonFrames.merge(frames) { _, new in new }
                    }

                VoiceCallControlsBar(
                    viewModel: viewModel,
                    showExpandedControls: $showExpandedControls,
                    showEmojiReactions: $showEmojiReactions,
                    onEndCall: { router.back() }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }

            if viewModel.isGroupCall {
                participantMoreButtonsLayer
            }
        }
        .coordinateSpace(name: "voiceCallBody")
        .overlay {
            if showEmojiReactions {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) { showEmojiReactions = false }
                    }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .overlayPreferenceValue(VoiceCallMenuAnchorKey.self) { anchor in
            if !viewModel.isGroupCall {
                moreOptionsOverlay(anchor)
            }
        }
        .overlay {
            if viewModel.isGroupCall, menuParticipantID != nil {
                participantMenuOverlay
            }
        }
        .sheet(isPresented: $showMeetingMenu) {
            VoiceCallOwnerMenuSheet(
                isAllMuted: $viewModel.isAllSoundMuted,
                isAllRestricted: $viewModel.isAllRestricted,
                isScreenSharing: $viewModel.isScreenSharing,
                isOpenMeetingEnabled: $isOpenMeetingEnabled
            ) { action in
                handleOwnerAction(action)
            }
        }
        .sheet(isPresented: $showBlockSheet) {
            VoiceCallReportSheet(
                titleKey: "voice_call_block_alert_title",
                messageKey: "voice_call_block_alert_message",
                confirmKey: "block",
                onConfirm: { showBlockSheet = false },
                onCancel: { showBlockSheet = false }
            )
        }
        .sheet(isPresented: $showReportSheet) {
            VoiceCallReportSheet(
                titleKey: "voice_call_report_confirm_title",
                messageKey: "voice_call_report_confirm_message",
                confirmKey: "voice_call_report_yes",
                onConfirm: { showReportSheet = false },
                onCancel: { showReportSheet = false }
            )
        }
        .sheet(isPresented: $showAddPersonSheet) {
            AddPersonSheetView(
                excludedContactIDs: viewModel.excludedContactIDs,
                onAddParticipant: { contact in
                    withAnimation(.easeInOut(duration: 0.25)) { viewModel.addParticipant(contact) }
                }
            )
            .presentationDetents([.fraction(0.68), .large])
            .presentationCornerRadius(24)
        }
        .task {
            await viewModel.load(
                contactName: contactName,
                avatarURL: avatarURL,
                avatarAsset: avatarAsset,
                transitionsToVideo: transitionsToVideo
            )
        }
        .onAppear { startRingTimer() }
        .onDisappear { ringTask?.cancel() }
    }

    // MARK: - Participants

    @ViewBuilder
    private var participantsArea: some View {
        if viewModel.isGroupCall {
            VoiceCallParticipantsGrid(
                participants: viewModel.allParticipants,
                localParticipantID: viewModel.primaryParticipant.id,
                isScreenSharing: viewModel.isScreenSharing,
                screenShareName: viewModel.primaryParticipant.name,
                isMicEnabled: viewModel.isMicEnabled,
                isVideoEnabled: viewModel.isVideoEnabled,
                isAllRestricted: viewModel.isAllRestricted,
                onOpenMenu: { id in
                    menuAnchorFrame = tileButtonFrames[id] ?? .zero
                    withAnimation(.easeOut(duration: 0.18)) { menuParticipantID = id }
                }
            )
        } else {
            VoiceCallSingleCaller(
                contactName: contactName,
                avatarURL: avatarURL,
                avatarAsset: avatarAsset,
                isRaisedHand: viewModel.localIsRaisedHand,
                isMicEnabled: viewModel.isMicEnabled,
                isVideoEnabled: viewModel.isVideoEnabled,
                activeReaction: viewModel.localActiveReaction
            )
        }
    }

    /// Flat layer of three-dots buttons for the inline (non-scrolling) grid, positioned in
    /// the `voiceCallBody` space from collected tile frames. Rendering them as flat siblings
    /// (rather than per-tile `.overlay`s) keeps hit-testing independent of the grid geometry —
    /// a per-tile overlay button on the bottom-left cell of a 2×2 grid never received taps.
    @ViewBuilder
    private var participantMoreButtonsLayer: some View {
        if viewModel.allParticipants.count <= maxInlineParticipants {
            ForEach(viewModel.allParticipants) { participant in
                if participant.id != viewModel.primaryParticipant.id,
                   let rect = tileButtonFrames[participant.id] {
                    Button {
                        menuAnchorFrame = rect
                        withAnimation(.easeOut(duration: 0.18)) { menuParticipantID = participant.id }
                    } label: {
                        Image("calls-3dots")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("voice_call_more_options".localized)
                    .position(x: rect.midX, y: rect.midY)
                }
            }
        }
    }

    // MARK: - More options popovers

    @ViewBuilder
    private func moreOptionsOverlay(_ anchor: Anchor<CGRect>?) -> some View {
        if let anchor, showMoreOptions {
            GeometryReader { proxy in
                let rect = proxy[anchor]
                let menuWidth = VoiceCallMoreOptionsMenu.width
                let menuHeight = VoiceCallMoreOptionsMenu.height
                let isRTL = Locale.current.language.characterDirection == .rightToLeft
                let menuCenterX = isRTL
                    ? rect.minX + menuWidth / 2
                    : rect.maxX - menuWidth / 2
                let menuCenterY = rect.maxY + 8 + menuHeight / 2

                ZStack {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.15)) { showMoreOptions = false }
                        }

                    VoiceCallMoreOptionsMenu(
                        isSoundMuted: isRemoteSoundMuted,
                        isRestricted: isRemoteRestricted,
                        onToggleMute: {
                            withAnimation(.easeOut(duration: 0.15)) { isRemoteSoundMuted.toggle() }
                        },
                        onToggleRestrict: {
                            withAnimation(.easeOut(duration: 0.15)) { isRemoteRestricted.toggle() }
                        },
                        onBlock: {
                            showMoreOptions = false
                            showBlockSheet = true
                        },
                        onReport: {
                            showMoreOptions = false
                            showReportSheet = true
                        }
                    )
                    .position(x: menuCenterX, y: menuCenterY)
                    .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: isRTL ? .topLeading : .topTrailing)))
                }
            }
        }
    }

    private var participantMenuOverlay: some View {
        GeometryReader { geo in
            let menuWidth = VoiceCallMoreOptionsMenu.width
            let menuHeight = VoiceCallMoreOptionsMenu.height
            let margin: CGFloat = 8
            let controlsTop = geo.size.height - collapsedControlsReservedHeight
            let button = menuAnchorFrame

            let centerX = min(
                max(button.midX, menuWidth / 2 + margin),
                geo.size.width - menuWidth / 2 - margin
            )
            let belowTop = button.maxY + 6
            let fitsBelow = belowTop + menuHeight <= controlsTop - margin
            let topY = fitsBelow ? belowTop : max(button.minY - 6 - menuHeight, margin)
            let centerY = topY + menuHeight / 2

            ZStack {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) { menuParticipantID = nil }
                    }

                VoiceCallMoreOptionsMenu(
                    isSoundMuted: menuParticipantMuted,
                    isRestricted: isRemoteRestricted,
                    onToggleMute: {
                        withAnimation(.easeOut(duration: 0.15)) { toggleMuteForMenuParticipant() }
                    },
                    onToggleRestrict: {
                        withAnimation(.easeOut(duration: 0.15)) { isRemoteRestricted.toggle() }
                    },
                    onBlock: {
                        menuParticipantID = nil
                        showBlockSheet = true
                    },
                    onReport: {
                        menuParticipantID = nil
                        showReportSheet = true
                    }
                )
                .position(x: centerX, y: centerY)
                .transition(.opacity.combined(with: .scale(
                    scale: 0.92,
                    anchor: fitsBelow ? .top : .bottom
                )))
            }
        }
    }

    // MARK: - Actions

    private var menuParticipantMuted: Bool {
        guard let id = menuParticipantID else { return false }
        return viewModel.isParticipantMuted(id)
    }

    private func toggleMuteForMenuParticipant() {
        guard let id = menuParticipantID else { return }
        viewModel.toggleParticipantMute(id)
    }

    private func handleOwnerAction(_ action: VoiceCallOwnerAction) {
        showMeetingMenu = false
        switch action {
        case .muteAll:
            withAnimation(.easeOut(duration: 0.15)) { viewModel.toggleMuteAll() }
            viewModel.isMicEnabled = !viewModel.isAllSoundMuted
        case .restrictAll:
            withAnimation(.easeOut(duration: 0.15)) { viewModel.isAllRestricted.toggle() }
        case .toggleScreenShare:
            withAnimation(.easeInOut(duration: 0.25)) { viewModel.isScreenSharing.toggle() }
        case .report:
            showReportSheet = true
        }
    }

    private func startRingTimer() {
        guard transitionsToVideo else { return }
        ringTask?.cancel()
        ringTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            router.back()
            router.navigate(.videoCall(contactName: contactName, avatarURL: avatarURL))
        }
    }
}

// MARK: - Preview
#Preview("Voice Call — Colored") {
    ThemeManager.shared.select(.colored)
    return VoiceCallsView()
}
