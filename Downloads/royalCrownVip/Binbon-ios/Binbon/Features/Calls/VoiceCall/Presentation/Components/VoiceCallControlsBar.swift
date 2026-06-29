//
//  VoiceCallControlsBar.swift
//  Binbon
//

import SwiftUI

/// Bottom control stack: an expand chevron, the optional raise-hand / emoji row (which
/// swaps to an emoji picker), and the main rail (keypad, video, speaker, mic, end call).
struct VoiceCallControlsBar: View {

    @ObservedObject var viewModel: VoiceCallViewModel
    @Binding var showExpandedControls: Bool
    @Binding var showEmojiReactions: Bool
    let onEndCall: () -> Void

    private let buttonSize: CGFloat = 61
    private let quickEmojiReactions = ["😂", "😢", "🤔", "👏", "🎉", "❤️"]
    private let quickEmojiReactionAccessibilityKeys = [
        "voice_call_reaction_laugh",
        "voice_call_reaction_cry",
        "voice_call_reaction_think",
        "voice_call_reaction_clap",
        "voice_call_reaction_party",
        "voice_call_reaction_heart"
    ]

    /// 5pt when emoji picker is open; raise-hand row touches main rail with no overlap.
    private var topToMainSpacing: CGFloat { showEmojiReactions ? 5 : 0 }

    var body: some View {
        VStack(spacing: 8) {
            chevronButton
            panel
        }
        .animation(.easeOut(duration: 0.2), value: showExpandedControls)
        .animation(.easeOut(duration: 0.2), value: showEmojiReactions)
        .environment(\.layoutDirection, .leftToRight)
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
        } label: {
            Image(systemName: showExpandedControls ? "chevron.down" : "chevron.up")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white.opacity(0.92))
                .frame(width: 44, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            (showExpandedControls ? "voice_call_collapse_controls" : "voice_call_expand_controls").localized
        )
    }

    private var panel: some View {
        VStack(spacing: topToMainSpacing) {
            if showExpandedControls {
                if showEmojiReactions {
                    emojiReactionsCapsule
                        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .bottom)))
                } else {
                    expandedControlsCapsule
                        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .bottom)))
                }
            }

            mainControlsCapsule
        }
    }

    /// Six quick reactions — capsule frame only (Figma).
    private var emojiReactionsCapsule: some View {
        HStack(spacing: 10) {
            ForEach(Array(quickEmojiReactions.enumerated()), id: \.offset) { index, emoji in
                Button {
                    sendReaction(emoji)
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
        )
    }

    /// Raise hand + emoji row — matches main capsule gradient and button sizes.
    private var expandedControlsCapsule: some View {
        HStack(spacing: 16) {
            UtilityControlButton(
                icon: "raiseHand",
                accessibilityKey: "voice_call_raise_hand",
                buttonSize: buttonSize,
                iconSize: 28,
                iconWidth: 32,
                iconHeight: 40,
                action: { viewModel.toggleRaiseHand() }
            )

            UtilityControlButton(
                icon: "emoji",
                accessibilityKey: "voice_call_emoji",
                buttonSize: buttonSize,
                iconSize: 28,
                iconWidth: 39,
                iconHeight: 39,
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
        )
    }

    /// Main rail — 5 buttons (61×61 each) inside a capsule matching Figma (344×100 inner).
    private var mainControlsCapsule: some View {
        HStack(spacing: 8) {
            UtilityControlButton(
                icon: "calls-moreoption",
                accessibilityKey: "voice_call_keypad",
                buttonSize: buttonSize,
                iconSize: 28
            )

            UtilityControlButton(
                systemName: "video.fill",
                showsDisabledStrike: !viewModel.isVideoEnabled,
                accessibilityKey: "voice_call_video",
                buttonSize: buttonSize,
                iconSize: 28
            ) {
                viewModel.toggleVideo()
            }

            UtilityControlButton(
                icon: viewModel.isSpeakerMuted ? "calls-mute" : nil,
                systemName: viewModel.isSpeakerMuted ? nil : "speaker.wave.2.fill",
                accessibilityKey: "voice_call_speaker",
                buttonSize: buttonSize,
                iconSize: 28
            ) {
                viewModel.toggleSpeaker()
            }

            UtilityControlButton(
                icon: viewModel.isMicEnabled ? "calls-micr" : nil,
                systemName: viewModel.isMicEnabled ? nil : "mic.slash.fill",
                accessibilityKey: "voice_call_microphone",
                buttonSize: buttonSize,
                iconSize: 28
            ) {
                viewModel.toggleMicrophone()
            }

            endCallButton
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .background(
            Capsule(style: .continuous)
                .fill(AppColor.voiceCallControlsBarCapsuleGradient)
        )
    }

    private var endCallButton: some View {
        Button(action: onEndCall) {
            Image("calls-endcall")
                .resizable()
                .scaledToFit()
                .frame(width: 61, height: 61)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("voice_call_end".localized)
    }

    private func sendReaction(_ emoji: String) {
        viewModel.sendReaction(emoji)
        withAnimation(.easeOut(duration: 0.2)) {
            showEmojiReactions = false
            showExpandedControls = false
        }
    }
}
