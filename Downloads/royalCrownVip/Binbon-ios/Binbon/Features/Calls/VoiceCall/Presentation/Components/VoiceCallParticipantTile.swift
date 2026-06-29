//
//  VoiceCallParticipantTile.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 24/06/2026.
//

import SwiftUI

struct VoiceCallParticipantTile: View {

    enum Style {
        case featured
        case compact
    }

    let participant: CallParticipant
    var style: Style = .featured
    var showsControls: Bool = false
    var isMicMuted: Bool = false
    var isVideoOff: Bool = false
    var isRestricted: Bool = false

    @State private var floatingEmoji: String? = nil
    @State private var floatingOffset: CGFloat = 0
    @State private var floatingOpacity: CGFloat = 0

    private var avatarSize: CGFloat { style == .featured ? 88 : 64 }
    private var nameFontSize: CGFloat { style == .featured ? 18 : 15 }

    var body: some View {
        ZStack {
            tileBackground

            VStack(spacing: 10) {
                Spacer(minLength: 0)

                ZStack(alignment: .topTrailing) {
                    avatar
                        .frame(width: avatarSize, height: avatarSize)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )

                    if participant.isRaisedHand {
                        Text("✋")
                            .font(.system(size: style == .featured ? 22 : 18))
                            .offset(x: 6, y: -4)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(participant.name)
                    .font(.system(size: nameFontSize, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }
        }
        .overlay(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 6) {
                if isMicMuted {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }

                if isVideoOff {
                    Image(systemName: "video.slash.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }

                if isRestricted {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.orange.opacity(0.8))
                        .clipShape(Circle())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.top, showsControls ? 48 : 8)
            .padding(.trailing, 8)
        }
        
        .overlay(alignment: .bottom) {
            if let reaction = participant.activeReaction {
                Text(reaction)
                    .font(.system(size: style == .featured ? 32 : 24))
                    .padding(.bottom, 8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay {
            if floatingEmoji != nil {
                Text(floatingEmoji ?? "")
                    .font(.system(size: style == .featured ? 40 : 28))
                    .opacity(floatingOpacity)
                    .offset(y: floatingOffset)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .onChange(of: participant.activeReaction) { _, newReaction in
            if let emoji = newReaction {
                startFloatingEmoji(emoji)
            }
        }
    }

    private func startFloatingEmoji(_ emoji: String) {
        floatingEmoji = emoji
        floatingOffset = 40
        floatingOpacity = 1.0

        withAnimation(.easeOut(duration: 1.8)) {
            floatingOffset = -200
            floatingOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            floatingEmoji = nil
            floatingOffset = 0
        }
    }

    private var tileBackground: some View {
        GeometryReader { proxy in
            participantImage
                .frame(width: proxy.size.width, height: proxy.size.height)
                .blur(radius: 22)
                .overlay(Color.black.opacity(0.42))
                .clipped()
        }
    }

    @ViewBuilder
    private var participantImage: some View {
        if let avatarURL = participant.avatarURL {
            ImageView(avatarURL, placeholder: Image(participant.avatarAsset))
        } else {
            Image(participant.avatarAsset)
                .resizable()
                .scaledToFill()
        }
    }

    @ViewBuilder
    private var avatar: some View {
        if let avatarURL = participant.avatarURL {
            ImageView(avatarURL, placeholder: Image(participant.avatarAsset))
        } else {
            Image(participant.avatarAsset)
                .resizable()
                .scaledToFill()
        }
    }
}

#Preview {
    VoiceCallParticipantTile(
        participant: CallParticipant(
            name: "أحمد محمد",
            avatarURL: "https://i.pravatar.cc/150?img=12"
        )
    )
    .frame(height: 260)
    .padding()
    .background(Color.black)
}
