//
//  VideoCallControlsBar.swift
//  Binbon
//

import SwiftUI

/// Bottom panel of the video call. In `.standard` mode it shows the expand chevron, the
/// optional raise-hand / emoji row (which swaps to an emoji picker) and the main control
/// dock; in `.filters` / `.backgrounds` mode it swaps to the matching effect strip.
struct VideoCallControlsBar: View {

    @ObservedObject var viewModel: VideoCallViewModel
    @Binding var bottomPanelMode: VideoCallBottomPanelMode
    @Binding var showExpandedControls: Bool
    @Binding var showEmojiReactions: Bool
    @Binding var isHandRaised: Bool
    @Binding var selectedFilterIndex: Int
    @Binding var selectedBackgroundIndex: Int

    let filterEffects: [(key: String, color: Color)]
    let backgroundEffects: [(key: String, color: Color)]

    let onEndCall: () -> Void
    let onInteraction: () -> Void
    let onRequestMeetingMenu: () -> Void

    private let expandedControlButtonSize: CGFloat = 63
    private let quickEmojiReactions = ["😂", "😢", "🤔", "👏", "🎉", "❤️"]
    private let quickEmojiReactionAccessibilityKeys = [
        "voice_call_reaction_laugh", "voice_call_reaction_cry", "voice_call_reaction_think",
        "voice_call_reaction_clap",  "voice_call_reaction_party", "voice_call_reaction_heart"
    ]

    var body: some View {
        VStack(spacing: 0) {
            if bottomPanelMode == .standard {
                standardControls
                    .animation(.easeOut(duration: 0.2), value: showExpandedControls)
                    .animation(.easeOut(duration: 0.2), value: showEmojiReactions)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                CallEffectsStrip(
                    effects: bottomPanelMode == .filters ? filterEffects : backgroundEffects,
                    selectedIndex: bottomPanelMode == .filters ? $selectedFilterIndex : $selectedBackgroundIndex,
                    onClose: { withAnimation(.easeInOut(duration: 0.25)) { bottomPanelMode = .standard } },
                    onReset: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if bottomPanelMode == .filters { selectedFilterIndex = 0 }
                            else { selectedBackgroundIndex = 0 }
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: bottomPanelMode)
        .environment(\.layoutDirection, .leftToRight)
    }

    private var standardControls: some View {
        VStack(spacing: showEmojiReactions ? 5 : 0) {
            chevronButton
                .padding(.bottom, 4)

            if showExpandedControls {
                if showEmojiReactions {
                    emojiReactionsCapsule
                        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .bottom)))
                } else {
                    expandedControlsCapsule
                        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .bottom)))
                }
            }

            CallControlsDock(viewModel: viewModel, backgroundOpacity: 0.75, onEndCall: onEndCall)
        }
    }

    private var chevronButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) {
                if showExpandedControls {
                    showExpandedControls = false
                    showEmojiReactions = false
                } else {
                    showExpandedControls = true
                }
            }
            onInteraction()
        } label: {
            Image(systemName: showExpandedControls ? "chevron.down" : "chevron.up")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white.opacity(0.92))
                .frame(height: 28)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            (showExpandedControls ? "voice_call_collapse_controls" : "voice_call_expand_controls").localized
        )
        .highPriorityGesture(
            DragGesture(minimumDistance: 12)
                .onEnded { value in
                    if value.translation.height < -20 { onRequestMeetingMenu() }
                }
        )
    }

    private var expandedControlsCapsule: some View {
        HStack(spacing: 16) {
            UtilityControlButton(
                icon: "raiseHand",
                accessibilityKey: "voice_call_raise_hand",
                buttonSize: expandedControlButtonSize,
                isProminent: isHandRaised,
                iconWidth: 32,
                iconHeight: 40,
                showsBackground: false,
                action: {
                    withAnimation(.easeOut(duration: 0.2)) { isHandRaised.toggle() }
                }
            )
            UtilityControlButton(
                icon: "emoji",
                accessibilityKey: "voice_call_emoji",
                buttonSize: expandedControlButtonSize,
                iconWidth: 39,
                iconHeight: 39,
                showsBackground: false,
                action: {
                    withAnimation(.easeOut(duration: 0.2)) { showEmojiReactions = true }
                }
            )
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 10)
        .background(
            Capsule(style: .continuous)
                .fill(AppColor.voiceCallControlsBarCapsuleGradient)
                .opacity(0.75)
        )
    }

    private var emojiReactionsCapsule: some View {
        HStack(spacing: 10) {
            ForEach(Array(quickEmojiReactions.enumerated()), id: \.offset) { index, emoji in
                Button {
                    viewModel.sendReaction(emoji)
                    withAnimation(.easeOut(duration: 0.2)) {
                        showEmojiReactions = false
                        showExpandedControls = false
                    }
                } label: {
                    Text(emoji)
                        .font(.system(size: 28))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(quickEmojiReactionAccessibilityKeys[index].localized)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: 342)
        .background(
            Capsule(style: .continuous)
                .fill(AppColor.voiceCallControlsBarCapsuleGradient)
                .opacity(0.75)
        )
    }
}
