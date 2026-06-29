//
//  VoiceCallSingleCaller.swift
//  Binbon
//

import SwiftUI

/// Hero shown during a one-to-one call: large avatar, contact name and "calling…"
/// status, plus mic/video badges and the local reaction.
struct VoiceCallSingleCaller: View {

    let contactName: String
    let avatarURL: String?
    let avatarAsset: String
    let isRaisedHand: Bool
    let isMicEnabled: Bool
    let isVideoEnabled: Bool
    let activeReaction: String?

    var body: some View {
        VStack(spacing: 14) {
            Spacer(minLength: 0)

            ZStack(alignment: .topTrailing) {
                CallAvatarImage(avatarURL: avatarURL, avatarAsset: avatarAsset)
                    .frame(width: 118, height: 118)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))

                if isRaisedHand {
                    Text("✋")
                        .font(.system(size: 24))
                        .offset(x: 8, y: -6)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Text(contactName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text("voice_call_calling".localized)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 6) {
                if !isMicEnabled {
                    statusBadge(systemName: "mic.slash.fill")
                }
                if !isVideoEnabled {
                    statusBadge(systemName: "video.slash.fill", fontSize: 12)
                }
            }
            .padding(.top, 12)
            .padding(.trailing, 12)
        }
        .overlay(alignment: .bottom) {
            if let activeReaction {
                Text(activeReaction)
                    .font(.system(size: 36))
                    .padding(.bottom, 60)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private func statusBadge(systemName: String, fontSize: CGFloat = 14) -> some View {
        Image(systemName: systemName)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
    }
}
