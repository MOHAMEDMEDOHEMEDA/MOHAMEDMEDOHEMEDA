//
//  MessageConversationRow.swift
//  Binbon
//
//  One conversation card in the Messages list: gold-bordered brand-gradient
//  pill with a leading avatar, name + preview line, and trailing call / video
//  actions. Missed calls show a small red ✗ before the preview.
//

import SwiftUI
 
struct MessageConversationRow: View {

    /// Trailing indicator after the call/video actions.
    enum Accessory: Equatable {
        case none
        /// Gold favourite star (favourites tab).
        case star
        /// Green selection toggle (add-to-favourites picker).
        case selection(isOn: Bool)
    }

    let conversation: MessageConversation
    var accessory: Accessory = .none
    /// Shows a tappable mute glyph beside the call/video actions when the
    /// conversation is on "do not disturb".
    var isMuted: Bool = false
    var onCall: () -> Void = {}
    var onVideo: () -> Void = {}
    /// Tapping the mute glyph lifts "do not disturb" for this conversation.
    var onUnmute: () -> Void = {}

    @Environment(\.sizeScale) private var scale
    private func s(_ v: CGFloat) -> CGFloat { v * scale }

    var body: some View {
        HStack(spacing: s(12)) {
            avatar

            VStack(alignment: .leading, spacing: s(2)) {
                Text(conversation.name)
                    .font(.system(size: s(16), weight: .bold))
                    .foregroundStyle(.appText)
                    .lineLimit(1)

                HStack(spacing: s(4)) {
                    if conversation.previewKind.showsMissedMark {
                        Image("message-missed")
                            .resizable()
                            .frame(width: s(13), height: s(13))
                    }
                    Text(conversation.preview.localized)
                        .font(.system(size: s(12), weight: .bold))
                        .foregroundStyle(.appText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: s(8))

            if isMuted {
                actionButton(asset: "message-mute", size: 20, action: onUnmute)
            }
            HStack {
                actionButton(asset: "message-call", size: 20, action: onCall)
                actionButton(asset: "message-video", size: 31, action: onVideo)
            }
            accessoryView
        }
        .padding(.horizontal, s(12))
        .padding(.vertical, s(8))
        .frame(maxWidth: .infinity)
        .frame(height: s(56))
        .background(
            RoundedRectangle(cornerRadius: s(16), style: .continuous)
                .fill(AppColor.verificationGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: s(16), style: .continuous)
                .strokeBorder(AppColor.messageBolderColor, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: s(16), style: .continuous))
    }

    @ViewBuilder
    private var avatar: some View {
        Group {
            if let asset = conversation.avatarAsset {
                // Full circular avatar asset (e.g. the management logo).
                Image(asset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: s(45), height: s(45))
            } else {
                ImageView(conversation.avatarURL, placeholder: Image(systemName: "person.fill"))
                    .frame(width: s(45), height: s(45))
            }
        }
        .clipShape(Circle())
        .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .star:
            Image("message-star")
                .resizable()
                .scaledToFit()
                .frame(width: s(24), height: s(24))
                .padding(.leading, s(2))
        case .selection(let isOn):
            // Plain radio: stroked ring with a green dot inside when selected.
            ZStack {
                Circle().strokeBorder(Color.white, lineWidth: 2)
                if isOn {
                    Circle().fill(Color.green).padding(s(4))
                }
            }
            .frame(width: s(22), height: s(22))
            .padding(.leading, s(2))
        }
    }

    private func actionButton(asset: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: s(size), height: s(size))
                .foregroundStyle(.white)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
 
#Preview {
    VStack(spacing: 14) {
        ForEach(MessageConversation.samples) { MessageConversationRow(conversation: $0) }
    }
    .padding()
    .appBackground()
}
