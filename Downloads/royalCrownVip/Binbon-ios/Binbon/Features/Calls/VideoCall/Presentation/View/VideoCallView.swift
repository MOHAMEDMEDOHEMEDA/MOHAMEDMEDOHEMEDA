//  VideoCallView.swift
//  Binbon
//
//  Created by Mohamed Magdy on 23/06/2026.
//

import SwiftUI

struct VideoCallView: View {

    let contactName: String
    let avatarURL: String?

    @Environment(\.router) private var router
    @StateObject private var viewModel: VideoCallViewModel
    @StateObject private var cameraManager = CameraManager()
    @State private var isAddParticipantPresented = false
    @State private var showMeetingMenu = false
    @State private var menuParticipantID: String?
    @State private var menuParticipantName: String = ""
    @State private var bottomPanelMode: VideoCallBottomPanelMode = .standard
    @State private var selectedFilterIndex: Int = 0
    @State private var selectedBackgroundIndex: Int = 0
    @State private var isOpenMeetingMode = true
    @State private var showVideoOptionsMenu = false
    @State private var isRemoteSoundMuted = false
    @State private var isRemoteRestricted = false
    @State private var isChooseVideoAccessPresented = false
    @State private var isAllSoundMuted = false
    @State private var isAllRestricted = false
    @State private var isAllVideoOff = false
    @State private var isScreenSharing = false
    @State private var showBlockSheet = false
    @State private var showReportSheet = false
    @State private var showReportProblemSheet = false
    @State private var controlsOpacity: CGFloat = 1.0
    @State private var fadeTimerTask: Task<Void, Never>?
    @State private var showExpandedControls = false
    @State private var showEmojiReactions = false
    @State private var isHandRaised = false

    private var isGroupCall: Bool {
        (viewModel.session?.participants ?? placeholderParticipants).count > 2
    }

    /// Gap between the pinned screen-share tile and the participant grid (matches the matrix's 2pt gaps).
    private let tileSpacing: CGFloat = 2

    private let filterEffects: [(key: String, color: Color)] = [
        ("voice_call_effect_none",     .clear),
        ("voice_call_effect_light",    Color(hex: "FFCF80")),
        ("voice_call_effect_space",    Color(hex: "1A1A6E")),
        ("voice_call_effect_soft",     Color(hex: "FF9EBD")),
        ("voice_call_effect_romantic", Color(hex: "C3385D")),
    ]

    private let backgroundEffects: [(key: String, color: Color)] = [
        ("voice_call_effect_none", .clear),
        ("voice_call_bg_blur",     Color(hex: "8BB8FF")),
        ("voice_call_bg_office",   Color(hex: "A0956E")),
        ("voice_call_bg_nature",   Color(hex: "3E8C46")),
        ("voice_call_bg_city",     Color(hex: "2C3E50")),
    ]

    @MainActor
    init(
        contactName: String = "أحمد محمد",
        avatarURL: String? = nil,
        viewModel: VideoCallViewModel? = nil
    ) {
        self.contactName = contactName
        self.avatarURL = avatarURL
        _viewModel = StateObject(wrappedValue: viewModel ?? VideoCallViewModel())
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { safeProxy in
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    Color.black

                    callTiles(size: proxy.size, safeBottom: safeProxy.safeAreaInsets.bottom)
                        .safeAreaInset(edge: .top, spacing: 0) {
                            VideoCallTopChrome(
                                durationText: viewModel.durationText,
                                isGroupCall: isGroupCall,
                                onMenu: { showVideoOptionsMenu = false; showMeetingMenu = true },
                                onAddPerson: { isAddParticipantPresented.toggle() },
                                onMore: { withAnimation(.easeOut(duration: 0.15)) { showVideoOptionsMenu.toggle() } },
                                onMinimize: { router.back() }
                            )
                            .padding(.top, safeProxy.safeAreaInsets.top)
                        }
                        .padding(.bottom, max(safeProxy.safeAreaInsets.bottom, 6))

                    VideoCallControlsBar(
                        viewModel: viewModel,
                        bottomPanelMode: $bottomPanelMode,
                        showExpandedControls: $showExpandedControls,
                        showEmojiReactions: $showEmojiReactions,
                        isHandRaised: $isHandRaised,
                        selectedFilterIndex: $selectedFilterIndex,
                        selectedBackgroundIndex: $selectedBackgroundIndex,
                        filterEffects: filterEffects,
                        backgroundEffects: backgroundEffects,
                        onEndCall: { router.back() },
                        onInteraction: { resetFadeTimer() },
                        onRequestMeetingMenu: { showMeetingMenu = true }
                    )
                    .opacity(controlsOpacity)
                    .padding(.horizontal, 17)
                    .padding(.bottom, max(safeProxy.safeAreaInsets.bottom, 12))
                }
                .overlayPreferenceValue(CallMoreMenuAnchorKey.self) { anchors in
                    ZStack {
                        participantMoreButtonsLayer(anchors: anchors)
                        participantMenuOverlay(anchors: anchors)
                    }
                }
                .overlay {
                    if showVideoOptionsMenu {
                        videoOptionsMenuOverlay
                    }
                }
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load(contactName: contactName, avatarURL: avatarURL)
            await cameraManager.start()
        }
        .onDisappear { cameraManager.stop() }
        .onChange(of: viewModel.isVideoEnabled) { _, enabled in
            if enabled { Task { await cameraManager.start() } } else { cameraManager.stop() }
        }
        .onAppear { resetFadeTimer() }
        .sheet(isPresented: $isAddParticipantPresented) {
            AddPersonSheetView(onAddParticipant: { conversation in
                let contact = CallContact(
                    id: conversation.id.uuidString,
                    displayName: conversation.name,
                    avatarURL: conversation.avatarURL
                )
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.addParticipant(contact)
                }
                isAddParticipantPresented = false
            })
            .presentationDetents([.fraction(0.68), .large])
            .presentationCornerRadius(24)
        }
        .sheet(isPresented: $isChooseVideoAccessPresented) {
            ChooseVideoAccessSheet(
                participants: viewModel.session?.participants ?? placeholderParticipants
            )
        }
        .sheet(isPresented: $showMeetingMenu) {
            CallMeetingActionsSheet(isOpenMeetingMode: $isOpenMeetingMode, isScreenSharing: $isScreenSharing) { action in
                handleMeetingAction(action)
            }
        }
        .sheet(isPresented: $showBlockSheet) {
            VoiceCallReportSheet(
                titleKey: "voice_call_block_alert_title",
                messageKey: "voice_call_block_alert_message",
                confirmKey: "block",
                messageArg: menuParticipantName,
                onConfirm: { showBlockSheet = false },
                onCancel: { showBlockSheet = false }
            )
        }
        .sheet(isPresented: $showReportSheet) {
            VoiceCallReportSheet(
                titleKey: "voice_call_report_alert_title",
                messageKey: "voice_call_report_alert_message",
                confirmKey: "report",
                messageArg: menuParticipantName,
                onConfirm: { showReportSheet = false },
                onCancel: { showReportSheet = false }
            )
        }
        .sheet(isPresented: $showReportProblemSheet) {
            VoiceCallReportSheet(
                titleKey: "voice_call_report_problem_alert_title",
                messageKey: "voice_call_report_problem_alert_message",
                confirmKey: "report",
                onConfirm: { showReportProblemSheet = false },
                onCancel: { showReportProblemSheet = false }
            )
        }
    }

    // MARK: - Tile Grid

    private func callTiles(size: CGSize, safeBottom: CGFloat) -> some View {
        var participants = viewModel.session?.participants ?? placeholderParticipants
        // Move the local tile to index 0 so it lands in the upper slot: the top
        // row when two are in the call, the full-width top slot (threeLayout), or
        // top-left (adaptiveGrid). This also keeps ALL non-local tiles in
        // positions that render their controls.
        if participants.count >= 2,
           let localIndex = participants.firstIndex(where: { $0.accent == .local }),
           localIndex != 0 {
            let local = participants.remove(at: localIndex)
            participants.insert(local, at: 0)
        }

        // When screen sharing, pin a screen-share tile above the grid and shrink the
        // matrix to fit underneath — mirrors the voice call's participants grid.
        let shareHeight = min(size.height * 0.4, 200)
        let matrixSize = isScreenSharing
            ? CGSize(width: size.width, height: max(size.height - shareHeight - tileSpacing, 0))
            : size
        let screenShareName = participants.first(where: { $0.accent == .local })?.name ?? contactName

        return VStack(spacing: tileSpacing) {
            if isScreenSharing {
                screenShareTile(height: shareHeight, name: screenShareName)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            VideoCallTileMatrix(
                participants: participants,
                geometrySize: matrixSize,
                gapInset: max(safeBottom, 4)
            ) { participant in
                tileWithEffects(participant: participant)
            }
        }
        .overlay(alignment: .leading) {
            VideoCallSideEffectButtons(bottomPanelMode: $bottomPanelMode)
                .opacity(controlsOpacity)
        }
        .contentShape(Rectangle())
        .onTapGesture { resetFadeTimer() }
    }

    /// Pinned screen-share tile shown above the participant grid, matching the
    /// voice call's `VoiceCallParticipantsGrid` screen-share tile.
    private func screenShareTile(height: CGFloat, name: String) -> some View {
        ZStack(alignment: .bottom) {
            Image("shareScreen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColor.voiceCallLocalBorder, lineWidth: 2)
                )

            Text("voice_call_screen_sharing_label".localizedFormat(name))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    @ViewBuilder
    private func tileWithEffects(participant: VideoCallParticipant) -> some View {
        let filterOn = selectedFilterIndex > 0
        let bgOn = selectedBackgroundIndex > 0
        let isLocal = participant.accent == .local
        let showCamera = isLocal && viewModel.isVideoEnabled && cameraManager.isAuthorized

        ZStack {
            CallParticipantTile(
                participant: displayParticipant(for: participant),
                isVideoOff: isLocal ? !viewModel.isVideoEnabled : (viewModel.isVideoOff(participant.id) || isAllVideoOff),
                isMuted: isLocal ? !viewModel.isMicEnabled : viewModel.isMuted(participant.id),
                isRestricted: !isLocal && isAllRestricted,
                showsControls: !isLocal
            )

            if showCamera {
                CameraPreviewView(session: cameraManager.session)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if isLocal && viewModel.isVideoEnabled && cameraManager.isAuthorized {
                Button {
                    cameraManager.flipCamera()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.45))
                        .clipShape(Circle())
                        .rotationEffect(.degrees(cameraManager.isFlipping ? 180 : 0))
                        .animation(.easeInOut(duration: 0.35), value: cameraManager.isFlipping)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("voice_call_flip_camera".localized)
                .padding(10)
            }
        }
        .overlay { if bgOn { backgroundEffects[selectedBackgroundIndex].color.opacity(0.40) } }
        .blur(radius: filterOn ? 2.5 : 0)
        .overlay { if filterOn { filterEffects[selectedFilterIndex].color.opacity(0.28) } }
        .animation(.easeInOut(duration: 0.3), value: selectedFilterIndex)
        .animation(.easeInOut(duration: 0.3), value: selectedBackgroundIndex)
    }

    // MARK: - Participant Three-Dots Buttons

    /// Flat layer of ⋯ buttons positioned from the per-tile anchors. Rendering them as flat
    /// siblings (rather than per-tile `.overlay`s) keeps hit-testing independent of the grid
    /// geometry — a per-tile overlay button on the bottom-left cell of a 2×2 grid never
    /// received taps (see bug-015). Tiles publish the anchor via CallMoreMenuAnchorKey.
    private func participantMoreButtonsLayer(anchors: [String: Anchor<CGRect>]) -> some View {
        GeometryReader { geo in
            ForEach(Array(anchors.keys), id: \.self) { id in
                if let anchor = anchors[id] {
                    let rect = geo[anchor]
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) { menuParticipantID = id }
                    } label: {
                        Image("calls-3dots")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 31, height: 8)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("voice_call_more_options".localized)
                    .position(x: rect.midX, y: rect.midY)
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - Participant Action Menu

    @ViewBuilder
    private func participantMenuOverlay(anchors: [String: Anchor<CGRect>]) -> some View {
        GeometryReader { geo in
            if let id = menuParticipantID,
               let participant = participant(for: id),
               let buttonAnchor = anchors[id] {

                let button = geo[buttonAnchor]
                let menuWidth: CGFloat = 210
                let menuHeight: CGFloat = 234
                let margin: CGFloat = 8

                let centerX = min(max(button.midX, menuWidth / 2 + margin),
                                  geo.size.width - menuWidth / 2 - margin)
                let belowTop = button.maxY + 6
                let fitsBelow = belowTop + menuHeight <= geo.size.height - margin
                let topY = fitsBelow ? belowTop : max(button.minY - 6 - menuHeight, margin)
                let centerY = topY + menuHeight / 2

                ZStack {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { dismissParticipantMenu() }

                    ParticipantActionMenu(
                        isVideoOff: viewModel.isVideoOff(participant.id),
                        isMuted: viewModel.isMuted(participant.id)
                    ) { action in
                        handleMenuAction(action, participant: participant)
                    }
                    .frame(width: menuWidth)
                    .environment(\.layoutDirection, .rightToLeft)
                    .position(x: centerX, y: centerY)
                    .transition(.scale(scale: 0.92, anchor: .top).combined(with: .opacity))
                }
            }
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    private func displayParticipant(for participant: VideoCallParticipant) -> VideoCallParticipant {
        var p = participant
        if participant.accent == .local {
            p = VideoCallParticipant(
                id: p.id,
                name: p.name + " (" + "voice_call_me".localized + ")",
                imageAsset: p.imageAsset,
                avatarURL: p.avatarURL,
                accent: p.accent,
                isRaisedHand: viewModel.localIsRaisedHand,
                activeReaction: viewModel.localActiveReaction
            )
        }
        return p
    }

    private func participant(for id: String) -> VideoCallParticipant? {
        let participants = viewModel.session?.participants ?? placeholderParticipants
        return participants.first { $0.id == id }
    }

    private func handleMenuAction(_ action: ParticipantMenuAction, participant: VideoCallParticipant) {
        switch action {
        case .toggleVideo: viewModel.toggleParticipantVideo(participant.id)
        case .toggleMute:  viewModel.toggleParticipantMute(participant.id)
        case .restrict:    viewModel.restrictParticipant(participant.id)
        case .block:
            menuParticipantName = participant.name
            dismissParticipantMenu()
            showBlockSheet = true
            return
        case .report:
            menuParticipantName = participant.name
            dismissParticipantMenu()
            showReportSheet = true
            return
        }
        dismissParticipantMenu()
    }

    private func dismissParticipantMenu() {
        withAnimation(.easeOut(duration: 0.15)) { menuParticipantID = nil }
    }

    private var placeholderParticipants: [VideoCallParticipant] {[
        VideoCallParticipant(id: "remote", name: contactName,                         imageAsset: "call-remote-video", avatarURL: nil, accent: .remote),
        VideoCallParticipant(id: "local",  name: "voice_call_local_contact".localized, imageAsset: "call-local-video",  avatarURL: nil, accent: .local),
    ]}

    // MARK: - Meeting Menu Actions

    private func videoToggleMuteAll() {
        withAnimation(.easeOut(duration: 0.15)) {
            isAllSoundMuted.toggle()
            let participants = viewModel.session?.participants ?? []
            for p in participants where p.accent != .local {
                if isAllSoundMuted {
                    viewModel.mutedParticipantIDs.insert(p.id)
                } else {
                    viewModel.mutedParticipantIDs.remove(p.id)
                }
            }
        }
    }

    private func videoMuteAllExceptOwner() {
        withAnimation(.easeOut(duration: 0.15)) {
            isAllSoundMuted = true
            let participants = viewModel.session?.participants ?? []
            for p in participants where p.accent != .local {
                viewModel.mutedParticipantIDs.insert(p.id)
            }
        }
    }

    // MARK: - Video Options Menu (Voice-style 3-dots)

    @Environment(\.layoutDirection) private var appLayoutDirection

    private var videoOptionsMenuOverlay: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) { showVideoOptionsMenu = false }
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
                        showVideoOptionsMenu = false
                        showBlockSheet = true
                    },
                    onReport: {
                        showVideoOptionsMenu = false
                        showReportSheet = true
                    }
                )
                .position(
                    x: proxy.size.width - VoiceCallMoreOptionsMenu.width / 2 - 16,
                    y: 60 + VoiceCallMoreOptionsMenu.height / 2
                )
                .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .topTrailing)))
            }
            .environment(\.layoutDirection, .leftToRight)
        }
    }

    private func resetFadeTimer() {
        withAnimation(.easeOut(duration: 0.25)) { controlsOpacity = 1.0 }
        fadeTimerTask?.cancel()
        fadeTimerTask = Task {
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.6)) { controlsOpacity = 0.3 }
            }
        }
    }

    private func handleMeetingAction(_ action: CallMeetingAction) {
        showMeetingMenu = false
        switch action {
        case .cameraAccess:
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(350))
                isChooseVideoAccessPresented = true
            }
        case .closeAllVideo:
            withAnimation(.easeOut(duration: 0.15)) { isAllVideoOff.toggle() }
        case .muteAll:
            videoToggleMuteAll()
        case .muteAllExceptOwner:
            videoMuteAllExceptOwner()
        case .restrictAll:
            withAnimation(.easeOut(duration: 0.15)) { isAllRestricted.toggle() }
        case .stopScreenShare:
            withAnimation(.easeOut(duration: 0.15)) { isScreenSharing.toggle() }
        case .report:
            showReportProblemSheet = true
        }
    }

}

// MARK: - Preview
#Preview("Video Call — Colored") {
    VideoCallView()
        .onAppear {
            ThemeManager.shared.select(.colored)
        }
}
