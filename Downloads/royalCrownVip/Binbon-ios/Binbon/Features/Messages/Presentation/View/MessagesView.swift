//
//  MessagesView.swift
//  Binbon
//
//  The Messages screen (الرسائل): brand-gradient backdrop, a profile block with
//  Do-Not-Disturb / Mood pills and a search field, relationship folder tabs, and
//  a panel of conversation cards. Mock-backed during the UI-only phase.
//

import SwiftUI

struct MessagesView: View {

    @Environment(\.router) private var router
    @StateObject private var viewModel = MessagesViewModel()
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
      GeometryReader { geo in
        let scale = min(geo.size.width, 640) / 375
        VStack(spacing: 0) {
            header(scale)
            profileBlock(scale)
                .padding(.horizontal, 24 * scale)
                .padding(.top, 14 * scale)
                .padding(.bottom, 18 * scale)

            ConversationUnionView(viewModel: viewModel)
                .padding(.top, 20 * scale)
        }
        .environment(\.sizeScale, scale)
        .adaptiveContentWidth()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .overlayPreferenceValue(PillAnchorKey.self) { anchor in popupOverlay(anchor) }
        .overlay { contextMenuOverlay }
        .overlay { addToGroupOverlay }
        .fullScreenCover(isPresented: $viewModel.isAddingToFavorites) {
            AddToFavoritesView(
                candidates: viewModel.favoriteCandidates,
                initialSelection: viewModel.favoriteSeed.map { [$0.id] } ?? [],
                onSend: { viewModel.addToFavorites($0) },
                onClose: { viewModel.cancelAddToFavorites() }
            )
        }
        .fullScreenCover(isPresented: $viewModel.isMovingToGroup) {
            MoveToGroupFlow(
                people: viewModel.groupCandidates,
                groups: viewModel.groupDestinations,
                seed: viewModel.groupSeed.map { [$0.id] } ?? [],
                onMove: { viewModel.finishMoveToGroup() },
                onClose: { viewModel.cancelMoveToGroup() }
            )
        }
        .sheet(item: $viewModel.reportFriend) { friend in
            NavigationStack {
                FriendReportReasonsView(friend: friend)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear { viewModel.load() }
      }
    }

    // MARK: - Header popovers (Mood / Do Not Disturb)

    @ViewBuilder
    private func popupOverlay(_ anchor: Anchor<CGRect>?) -> some View {
        if let anchor, let popup = viewModel.activePopup {
            GeometryReader { proxy in
                let rect = proxy[anchor]
                ZStack(alignment: .topLeading) {
                    // Tap-anywhere scrim to dismiss.
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation(.easeOut(duration: 0.15)) { viewModel.closePopup() } }

                    dialog(for: popup)
                        .fixedSize()
                        .position(x: rect.midX, y: rect.maxY + 8)
                        .offset(y: dialogHalfHeight(for: popup))
                        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .top)))
                }
            }
        }
    }

    @ViewBuilder
    private func dialog(for popup: MessagesPopup) -> some View {
        switch popup {
        case .mood:
            MoodDialog { viewModel.selectTheme($0) }
        case .doNotDisturb:
            DoNotDisturbDialog(selected: viewModel.doNotDisturbMode) { viewModel.selectDoNotDisturb($0) }
        }
    }

    /// `position` centers the dialog on the anchor point, so nudge it down by
    /// half its height to hang it below the pill.
    private func dialogHalfHeight(for popup: MessagesPopup) -> CGFloat {
        popup == .mood ? 80 : 48
    }

    // MARK: - Row long-press context menu

    @ViewBuilder
    private var contextMenuOverlay: some View {
        if viewModel.contextMenuConversation != nil {
            ZStack {
                // Dim the rest of the list; tap anywhere to dismiss.
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) { viewModel.closeContextMenu() }
                    }

                MessageRowMenu { viewModel.performRowAction($0) }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
    }

    // MARK: - Add-to-group dialog

    @ViewBuilder
    private var addToGroupOverlay: some View {
        if viewModel.isAddingToGroup {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) { viewModel.cancelAddToGroup() }
                    }

                AddToGroupDialog { viewModel.addToGroup($0) }
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
    }

    // MARK: - Header

    private func header(_ scale: CGFloat) -> some View {
        ZStack {
            Text("messages".localized)
                .font(.system(size: 21 * scale, weight: .bold))
                .foregroundStyle(.appText)

            HStack {
                if router.canBack() {
                    Button { router.back() } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundStyle(.appText)
                            .frame(width: 32 * scale, height: 32 * scale)
                            .contentShape(Rectangle())
                    }
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16 * scale)
        .frame(height: 44 * scale)
    }

    // MARK: - Profile block (avatar + name/id, pills + search)

    private func profileBlock(_ scale: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 14 * scale) {
            VStack {
                avatar(scale)
                Text(Storage.shared.user?.fullname ?? Storage.shared.user?.username ?? "Hamza")
                    .font(.system(size: 16 * scale, weight: .bold))
                    .foregroundStyle(.appText)
                    .lineLimit(1)
                Text("messages_user_id".localizedFormat("23432443"))
                    .font(.system(size: 10 * scale, weight: .bold))
                    .foregroundStyle(.appText)
            }

            VStack(spacing: 30 * scale) {
                HStack(spacing: 16 * scale) {
                    pill(title: "messages_do_not_disturb".localized,
                         popup: .doNotDisturb,
                         isActive: viewModel.doNotDisturbActive,
                         scale: scale)
                    pill(title: "messages_mood".localized,
                         popup: .mood,
                         isActive: viewModel.activePopup == .mood,
                         scale: scale)
                }
                searchField(scale)
            }
        }
    }

    private func avatar(_ scale: CGFloat) -> some View {
        ImageView(Storage.shared.user?.profilePhoto, placeholder: Image(systemName: "person.fill"))
            .frame(width: 67 * scale, height: 67 * scale)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(AppColor.messageBolderColor, lineWidth: 3))
    }

    private func pill(title: String, popup: MessagesPopup, isActive: Bool, scale: CGFloat) -> some View {
        Button {
            if popup == .mood {
                router.navigate(.themeSetting)
            } else {
                withAnimation(.easeOut(duration: 0.15)) { viewModel.togglePopup(popup) }
            }
        } label: {
            Text(title)
                .font(.system(size: 11 * scale, weight: .bold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 16 * scale)
                .padding(.vertical, 7 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 8 * scale).fill(AnyShapeStyle(AppColor.voiceCallControlButtonFillGredient)
                                                                  ))
                .overlay(RoundedRectangle(cornerRadius: 7 * scale).stroke(AppColor.messageBolderColor, lineWidth: 3))
        }
        .buttonStyle(.plain)
        .anchorPreference(key: PillAnchorKey.self, value: .bounds) {
            viewModel.activePopup == popup ? $0 : nil
        }
    }

    private func searchField(_ scale: CGFloat) -> some View {
        HStack(spacing: 8 * scale) {
            TextField("", text: $viewModel.searchText, prompt:
                        Text("messages_search_placeholder".localized)
                .foregroundColor(.appText))
            .font(.system(size: 10 * scale, weight: .medium))
            .foregroundStyle(.appText)
            
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14 * scale, weight: .semibold))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 16 * scale)
        .padding(.vertical, 6 * scale)
        .background(RoundedRectangle(cornerRadius: 8 * scale).fill(Color.clear))
        .overlay(RoundedRectangle(cornerRadius: 8 * scale).stroke(.appText, lineWidth: 1))
    }

}

// MARK: - Conversation union (scrollable folder tabs, continuous gold outline)

/// Owns the chip-frame tracking so a frame update during the tab-switch scroll
/// only redraws the ear shape — the tab strip and the conversation list are
/// separate views with stable inputs, so they're skipped on those updates.
private struct ConversationUnionView: View {

    @ObservedObject var viewModel: MessagesViewModel
    @Environment(\.sizeScale) private var scale

    // Each chip's live frame in the union coordinate space, so the selected ear
    // can sit exactly on its chip — including while the strip scrolls.
    @State private var chipFrames: [MessageFilterTab: CGRect] = [:]

    private var tabEarHeight: CGFloat { 39 * scale }
    private var tabCornerRadius: CGFloat { 8 * scale }

    /// x-range of the selected chip, read straight from its measured frame.
    private var selectedEarX: (min: CGFloat, max: CGFloat) {
        if let frame = chipFrames[viewModel.selectedTab] {
            return (min: frame.minX, max: frame.maxX)
        }
        return (min: 10 * scale, max: 80 * scale)
    }

    var body: some View {
        VStack(spacing: 0) {
            TabStripView(viewModel: viewModel, earHeight: tabEarHeight, cornerRadius: tabCornerRadius)
            ConversationListView(viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "union")
        // Gradient fill sits behind the chips.
        .background { unionFill }
        // Gold stroke overlays on top of the chips so unselected tabs appear
        // visually beneath the panel border — matching the Figma layer order.
        .overlay { unionStroke }
        .onPreferenceChange(ChipFrameKey.self) { chipFrames = $0 }
    }

    private var unionFill: some View {
        let ear = selectedEarX
        return ScrollableUnionShape(
            earMinX: ear.min, earMaxX: ear.max,
            earHeight: tabEarHeight, cornerRadius: tabCornerRadius
        )
        .fill(LinearGradient(
            colors: [Color(hex: "934E8E"), Color(hex: "D56757")],
            startPoint: .top,
            endPoint: .bottom
        ))
        .environment(\.layoutDirection, .leftToRight)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedTab)
    }

    private var unionStroke: some View {
        let ear = selectedEarX
        return ScrollableUnionShape(
            earMinX: ear.min, earMaxX: ear.max,
            earHeight: tabEarHeight, cornerRadius: tabCornerRadius,
            closed: false
        )
        .stroke(AppColor.gold, lineWidth: 2)
        .environment(\.layoutDirection, .leftToRight)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.selectedTab)
    }
}

/// The horizontal folder-tab strip. Doesn't read `chipFrames`, so it isn't
/// rebuilt while the selected ear tracks the scroll.
private struct TabStripView: View {

    @ObservedObject var viewModel: MessagesViewModel
    @Environment(\.sizeScale) private var scale
    let earHeight: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(MessageFilterTab.allCases) { tab in
                        tabChip(tab)
                    }
                }
                .padding(.horizontal, 20 * scale)
            }
            .scrollClipDisabled()
            .frame(height: earHeight)
            .onChange(of: viewModel.selectedTab) { _, newTab in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    scrollProxy.scrollTo(newTab, anchor: .center)
                }
            }
        }
    }

    private func tabChip(_ tab: MessageFilterTab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        let allTabs = MessageFilterTab.allCases
        let selectedIdx = allTabs.firstIndex(of: viewModel.selectedTab) ?? -1
        let tabIdx = allTabs.firstIndex(of: tab) ?? -1
        // Inner corner radius for the tab immediately next to the selected ear.
        let innerRadius = cornerRadius * 3
        let bottomTrailing: CGFloat = (tabIdx == selectedIdx - 1) ? innerRadius : 0
        let bottomLeading: CGFloat  = (tabIdx == selectedIdx + 1) ? innerRadius : 0

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                viewModel.select(tab)
            }
        } label: {
            Text(tab.titleKey.localized)
                .font(.system(size: 12 * scale, weight: isSelected ? .bold : .semibold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 20 * scale)
                .frame(minWidth: 59 * scale)
                .frame(height: earHeight)
                .background {
                    if isSelected {
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ChipFrameKey.self,
                                value: [tab: geo.frame(in: .named("union"))]
                            )
                        }
                    } else {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: bottomLeading,
                            bottomTrailingRadius: bottomTrailing,
                            topTrailingRadius: 0
                        )
                        .fill(AppColor.backgroundGradientApp)
                    }
                }
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(isSelected ? 0 : 0.45), radius: 6, x: 0, y: 4)
        .id(tab)
    }
}

/// The vertical conversation list. Its only input is the view model, so a
/// chip-frame change in the parent doesn't rebuild this (often heavy) list.
private struct ConversationListView: View {

    @ObservedObject var viewModel: MessagesViewModel
    @Environment(\.router) private var router
    @Environment(\.sizeScale) private var scale

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12 * scale) {
                ForEach(viewModel.visibleConversations) { conversation in
                    MessageConversationRow(
                        conversation: conversation,
                        accessory: viewModel.selectedTab == .favorites ? .star : .none,
                        isMuted: viewModel.isMuted(conversation),
                        onCall: {
                            router.navigate(.voiceCall(
                                contactName: conversation.name,
                                avatarURL: conversation.avatarURL,
                                transitionsToVideo: false
                            ))
                        }, onVideo: {
                            router.navigate(.voiceCall(
                                contactName: conversation.name,
                                avatarURL: conversation.avatarURL,
                                transitionsToVideo: true
                            ))
                        }, onUnmute: { viewModel.unmute(conversation) }
                    )
                        .onTapGesture { router.navigate(.chat(conversation)) }
                        // simultaneousGesture so the long press doesn't swallow
                        // the ScrollView's vertical drag.
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.4).onEnded { _ in
                                withAnimation(.easeOut(duration: 0.18)) {
                                    viewModel.openContextMenu(conversation)
                                }
                            }
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24 * scale)
            .padding(.top, 14 * scale)
            .padding(.bottom, 24 * scale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Move-to-group flow (pick people → choose group)

/// Two-step "نقل الى مجموعة" flow: the people picker pushes the group chooser
/// on "التالي"; the chooser's "نقل" hands control back to close the flow.
private struct MoveToGroupFlow: View {

    let people: [MessageConversation]
    let groups: [MessageConversation]
    let seed: Set<UUID>
    let onMove: () -> Void
    let onClose: () -> Void

    @State private var showGroupChooser = false

    var body: some View {
        NavigationStack {
            AddToFavoritesView(
                candidates: people,
                initialSelection: seed,
                titleKey: "messages_move_group_title",
                actionKey: "messages_next",
                onSend: { _ in showGroupChooser = true },
                onClose: onClose
            )
            .navigationDestination(isPresented: $showGroupChooser) {
                AddToFavoritesView(
                    candidates: groups,
                    initialSelection: [],
                    titleKey: "messages_select_group_title",
                    actionKey: "messages_move",
                    onSend: { _ in onMove() },
                    onClose: { showGroupChooser = false }
                )
            }
        }
    }
}

// MARK: - Scrollable union shape

/// A direct port of `CommentsUnionShape` where the selected ear is positioned
/// by absolute x-coordinates instead of a slot index — so it can track the
/// currently-visible chip as the tab strip scrolls.
private struct ScrollableUnionShape: Shape {
    var earMinX: CGFloat
    var earMaxX: CGFloat
    var earHeight: CGFloat
    var cornerRadius: CGFloat
    var portal: CGFloat = 35
    /// When false the path is open along the bottom (for stroke-only use).
    var closed: Bool = true

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(earMinX, earMaxX) }
        set { earMinX = newValue.first; earMaxX = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let r = cornerRadius
        // pw is the junction curve radius. Clamped so the curve never exceeds
        // the ear height (minus the top corner radius) or 60% of the ear width,
        // producing the large sweeping quarter-circle visible in the Figma design.
        let pw = min(portal, max(0, earMaxX - earMinX) * 0.6, earHeight - cornerRadius)
        let eS = earMinX
        let eE = earMaxX

        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))

        // The selected ear only exists while its chip overlaps the visible strip;
        // once the chip scrolls fully off either side, draw a plain panel top.
        let earVisible = eE > 0 && eS < w

        guard earVisible else {
            p.addLine(to: CGPoint(x: 0, y: earHeight + r))
            p.addQuadCurve(to: .init(x: r, y: earHeight), control: .init(x: 0, y: earHeight))
            p.addLine(to: CGPoint(x: w - r, y: earHeight))
            p.addQuadCurve(to: .init(x: w, y: earHeight + r), control: .init(x: w, y: earHeight))
            p.addLine(to: CGPoint(x: w, y: h))
            if closed { p.addLine(to: .init(x: 0, y: h)); p.closeSubpath() }
            return p
        }

        // Leading edge → up to the ear's left wall. The panel's top-left corner
        // is clamped to the room before the ear (`rL`) so it never overshoots the
        // wall; once that room is gone (chip at/under the left edge) the ear meets
        // the edge and we rise straight up.
        if eS - pw <= 0 {
            p.addLine(to: CGPoint(x: 0, y: 0))
        } else {
            let rL = min(r, eS - pw)
            p.addLine(to: CGPoint(x: 0, y: earHeight + rL))
            p.addQuadCurve(to: .init(x: rL, y: earHeight), control: .init(x: 0, y: earHeight))
            p.addLine(to: CGPoint(x: eS - pw, y: earHeight))
            p.addQuadCurve(to: .init(x: eS, y: earHeight - pw), control: .init(x: eS, y: earHeight))
            p.addLine(to: CGPoint(x: eS, y: r))
            p.addQuadCurve(to: .init(x: eS + r, y: 0), control: .init(x: eS, y: 0))
        }

        // Across the ear top → down the right wall, mirroring the left with the
        // trailing-corner clamp (`rR`).
        if (w - eE) - pw <= 0 {
            p.addLine(to: CGPoint(x: w, y: 0))
        } else {
            let rR = min(r, (w - eE) - pw)
            p.addLine(to: CGPoint(x: eE - r, y: 0))
            p.addQuadCurve(to: .init(x: eE, y: r), control: .init(x: eE, y: 0))
            p.addLine(to: CGPoint(x: eE, y: earHeight - pw))
            p.addQuadCurve(to: .init(x: eE + pw, y: earHeight), control: .init(x: eE, y: earHeight))
            p.addLine(to: CGPoint(x: w - rR, y: earHeight))
            p.addQuadCurve(to: .init(x: w, y: earHeight + rR), control: .init(x: w, y: earHeight))
        }

        p.addLine(to: CGPoint(x: w, y: h))

        if closed {
            p.addLine(to: CGPoint(x: 0, y: h))
            p.closeSubpath()
        }
        return p
    }
}

// MARK: - Preference keys

private struct ChipFrameKey: PreferenceKey {
    static var defaultValue: [MessageFilterTab: CGRect] = [:]
    static func reduce(value: inout [MessageFilterTab: CGRect], nextValue: () -> [MessageFilterTab: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

private struct PillAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

#Preview {
    MessagesView()
}
