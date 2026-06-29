//  CallControlsDock.swift
//  Binbon

import SwiftUI

struct CallControlsDock: View {

    @ObservedObject var viewModel: VideoCallViewModel
    var buttonSize: CGFloat = 46
    var backgroundOpacity: CGFloat = 1.0
    let onEndCall: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            UtilityControlButton(
                icon: "calls-moreoption",
                accessibilityKey: "voice_call_keypad"
            )

            UtilityControlButton(
                systemName: "video.fill",
                showsDisabledStrike: !viewModel.isVideoEnabled,
                accessibilityKey: "voice_call_video"
            ) { viewModel.toggleVideo() }

            UtilityControlButton(
                icon: viewModel.isSpeakerEnabled ? nil : "calls-mute",
                systemName: viewModel.isSpeakerEnabled ? "speaker.wave.2.fill" : nil,
                accessibilityKey: "voice_call_speaker"
            ) { viewModel.toggleSpeaker() }

            UtilityControlButton(
                icon: viewModel.isMicEnabled ? "calls-micr" : nil,
                systemName: viewModel.isMicEnabled ? nil : "mic.slash.fill",
                accessibilityKey: "voice_call_microphone"
            ) { viewModel.toggleMicrophone() }

            Button(action: onEndCall) {
                Image("calls-endcall")
                    .resizable()
                    .scaledToFit()
                    .frame(width: buttonSize, height: buttonSize)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("voice_call_end".localized)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: 342)
        .background(
            Capsule(style: .continuous)
                .fill(AppColor.voiceCallControlsBarCapsuleGradient)
                .opacity(backgroundOpacity)
        )
    }
}
