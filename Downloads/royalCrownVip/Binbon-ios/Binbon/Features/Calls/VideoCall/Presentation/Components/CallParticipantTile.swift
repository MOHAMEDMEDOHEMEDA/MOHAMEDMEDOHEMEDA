//
//  CallParticipantTile.swift
//  Binbon
//
//  Created by Mohamed Magdy on 23/06/2026.
//

import SwiftUI

/// Publishes each tile's ⋯ button frame (keyed by participant id) so the screen
/// can anchor the action popover to the exact button position — RTL-safe.
struct CallMoreMenuAnchorKey: PreferenceKey {
    static let defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct CallParticipantTile: View {

    let participant: VideoCallParticipant
    var isVideoOff: Bool = false
    var isMuted: Bool = false
    var isRestricted: Bool = false
    var showsControls: Bool = true

    @State private var floatingEmoji: String? = nil
    @State private var floatingOffset: CGFloat = 0
    @State private var floatingOpacity: CGFloat = 0
    @State private var resolvedImage: UIImage?

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                if isVideoOff {
                    videoOffContent(size: geo.size)
                } else {
                    participantImage
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()

                    AppColor.voiceCallVideoScrim
                        .frame(width: geo.size.width, height: geo.size.height)

                    nameLabel
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 4)
        }
        .overlay(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 6) {
                if showsControls {
                    moreButtonAnchor
                }

                if isMuted {
                    statusIcon(systemName: "mic.slash.fill")
                }

                if isVideoOff {
                    statusIcon(systemName: "video.slash.fill", fontSize: 11)
                }

                if isRestricted {
                    statusIcon(systemName: "lock.fill", fontSize: 11, tint: .orange)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .overlay(alignment: .topLeading) {
            if participant.isRaisedHand {
                Text("✋")
                    .font(.system(size: 22))
                    .padding(8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay(alignment: .bottom) {
            if let reaction = participant.activeReaction {
                Text(reaction)
                    .font(.system(size: 32))
                    .padding(.bottom, 8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .overlay {
            if floatingEmoji != nil {
                Text(floatingEmoji ?? "")
                    .font(.system(size: 40))
                    .opacity(floatingOpacity)
                    .offset(y: floatingOffset)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(participant.name)
        .onChange(of: participant.activeReaction) { _, newReaction in
            if let emoji = newReaction {
                startFloatingEmoji(emoji)
            }
        }
        .task(id: participant.avatarURL) {
            resolvedImage = await loadImage()
        }
    }

    private func statusIcon(systemName: String, fontSize: CGFloat = 13, tint: Color = Color.black.opacity(0.5)) -> some View {
        Image(systemName: systemName)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(tint)
            .clipShape(Circle())
            .padding(.trailing, 10)
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

    // MARK: - Video off

    private func videoOffContent(size: CGSize) -> some View {
        ZStack {
            participantImage
                .frame(width: size.width, height: size.height)
                .clipped()
                .blur(radius: 18)
                .overlay(Color.black.opacity(0.45))

            VStack(spacing: 12) {
                avatarCircle
                Text(participant.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
                    .padding(.horizontal, 16)
            }
        }
    }

    private var avatarCircle: some View {
        participantImage
            .frame(width: avatarDiameter, height: avatarDiameter)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(borderColor, lineWidth: 3))
            .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
    }

    private var avatarDiameter: CGFloat { 96 }

    // MARK: - Shared pieces

    private var nameLabel: some View {
        Text(participant.name)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
            .padding(.top, 14)
            .padding(.horizontal, 56)
    }

    /// Reserves the ⋯ button's slot (keeping the status-icon column layout intact) and
    /// publishes its frame, but is NOT the tappable control: the actual button is rendered as
    /// a flat layer in VideoCallView. A per-tile button here doesn't receive taps on the
    /// bottom-left cell of a 2×2 grid (see bug-015).
    private var moreButtonAnchor: some View {
        Color.clear
            .frame(width: 44, height: 44)
            .padding(.top, 6)
            .padding(.trailing, 4)
            .anchorPreference(key: CallMoreMenuAnchorKey.self, value: .bounds) { [participant.id: $0] }
    }

    private var borderColor: Color {
        switch participant.accent {
        case .remote: return AppColor.voiceCallRemoteBorder
        case .local: return AppColor.voiceCallLocalBorder
        }
    }

    private func loadImage() async -> UIImage? {
        guard let urlString = participant.avatarURL else { return nil }
        if !urlString.lowercased().hasPrefix("http") {
            return UIImage(named: urlString)
        }
        if let url = URL(string: urlString), let cached = Network.shared.imageCache[url] {
            return cached
        }
        return await Network.shared.image(urlString)
    }

    /// All three rendering sites (live video, blurred background, avatar circle) share
    /// this single computed view, which reads from `resolvedImage` — loaded once by the
    /// single .task on the tile — so there are no per-site async loads or @State copies.
    private var participantImage: some View {
        Group {
            if let img = resolvedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(participant.imageAsset)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

