//
//  ChatMessageContextMenu.swift
//  Binbon
//
//  Created by Aya Mashaly on 24/06/2026.
//

import SwiftUI
import UIKit

enum ChatContextAction: CaseIterable {
    case reply
    case forward
    case copy
    case pin
    case star
    case replyPrivate
    case messageAdmin
    case translate
    case report
    case delete

    var titleKey: String {
        switch self {
        case .reply:        return "chat_ctx_reply"
        case .forward:      return "chat_ctx_forward"
        case .copy:         return "chat_ctx_copy"
        case .pin:          return "chat_ctx_pin"
        case .star:         return "chat_ctx_star"
        case .replyPrivate: return "chat_ctx_reply_private"
        case .messageAdmin: return "chat_ctx_message_admin"
        case .translate:    return "chat_ctx_translate"
        case .report:       return "chat_ctx_report"
        case .delete:       return "chat_ctx_delete"
        }
    }

    var icon: String {
        switch self {
        case .reply:        return "arrowshape.turn.up.right.fill"
        case .forward:      return "arrowshape.turn.up.left.fill"
        case .copy:         return "doc.on.doc"
        case .pin:          return "pin"
        case .star:         return "star"
        case .replyPrivate: return "arrowshape.turn.up.right"
        case .messageAdmin: return "bubble.left"
        case .translate:    return "translate"
        case .report:       return "exclamationmark.triangle"
        case .delete:       return "trash.fill"
        }
    }

    var isDestructive: Bool { self == .delete }
}

struct ChatMessageContextMenu: View {
    let message: ChatMessage
    var anchorY: CGFloat = 0
    var participantName: String = ""
    let onDismiss: () -> Void
    let onAction: (ChatContextAction) -> Void
    var onReact: ((String) -> Void)? = nil
    var showMenuItems: Bool = true

    @State private var showEmojiPicker = false
    @State private var keyboardHeight: CGFloat = 0

    private let quickReactions = [
        "👍",
        "❤️",
        "😂",
        "😮",
        "😢",
        "🙏",
        "😒"
    ]
    private let condensedActions: [ChatContextAction] = [.reply, .forward, .copy, .delete]

    var body: some View {
        if showMenuItems {
            fullContextMenu
        } else {
            lightEmojiBar
        }
    }

    private var fullContextMenu: some View {
        ZStack {
            backdrop

            VStack(alignment: .leading, spacing: 12) {
                emojiBar
                messageBubblePreview
                fullMenuCard.frame(width: 193)
            }
            .padding(.horizontal, 24)
            .offset(y: showEmojiPicker ? keyboardHeight * 0.4 : 0)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)

            if showEmojiPicker {
                EmojiKeyboardField(isActive: $showEmojiPicker) { emoji in
                    onReact?(emoji)
                    onDismiss()
                }
                .frame(width: 1, height: 1)
                .opacity(0)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
            guard let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = frame.height
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }

    private var lightEmojiBar: some View {
        let emojiBarHeight: CGFloat = 52
        let gap: CGFloat = 50
        let topOffset = max(60, anchorY - emojiBarHeight - gap)

        return ZStack(alignment: .top) {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    if showEmojiPicker { showEmojiPicker = false } else { onDismiss() }
                }

            emojiBar
                .padding(.horizontal, 24)
                .padding(.top, topOffset)

            if showEmojiPicker {
                EmojiKeyboardField(isActive: $showEmojiPicker) { emoji in
                    onReact?(emoji)
                    onDismiss()
                }
                .frame(width: 1, height: 1)
                .opacity(0)
            }
        }
    }

    // MARK: - Backdrop

    private var backdrop: some View {
        Rectangle()
            .fill(.ultraThinMaterial.opacity(0.85))
            .ignoresSafeArea()
            .onTapGesture {
                if showEmojiPicker {
                    showEmojiPicker = false
                } else {
                    onDismiss()
                }
            }
    }

    // MARK: - Message bubble preview

    private var isMine: Bool { message.sender == .me }

    private var messageBubblePreview: some View {
        let color: Color = isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble
        return VStack(spacing: 6) {
            if let reply = message.replyTo {
                replyQuotePreview(reply)
            }
            bubblePreviewContent
            Text(message.time)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.appText.opacity(0.65))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(color))
        .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: .leading)
    }

    private func replyQuotePreview(_ info: ChatReplyInfo) -> some View {
        let senderName = info.sender == .me ? "chat_reply_me".localized : participantName
        return HStack(spacing: 0) {
            Rectangle()
                .fill(AppColor.chatReplySender)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text(senderName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColor.chatReplySender)
                    .lineLimit(1)
                Text(info.previewText)
                    .font(.system(size: 11))
                    .foregroundStyle(.appText.opacity(0.75))
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            Spacer(minLength: 0)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: 50)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(.black.opacity(0.15))
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    @ViewBuilder
    private var bubblePreviewContent: some View {
        switch message.kind {
        case .text:
            Text(message.text)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(3)
        case .images:
            Label("chat_pin_preview_photo".localized, systemImage: "photo")
                .font(.system(size: 13, weight: .semibold))
        case .voice, .audio:
            Label("chat_pin_preview_voice".localized, systemImage: "mic.fill")
                .font(.system(size: 13, weight: .semibold))
        case .video:
            Label("chat_pin_preview_video".localized, systemImage: "video.fill")
                .font(.system(size: 13, weight: .semibold))
        case .document(let name, _, _):
            Label(name, systemImage: "doc.fill")
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        case .location(_, _, let name):
            Label(name, systemImage: "location.fill")
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        case .sticker(let emoji, _):
            Text(emoji).font(.system(size: 40))
        case .iconSticker:
            Label("chat_pin_preview_sticker".localized, systemImage: "star.fill")
                .font(.system(size: 13, weight: .semibold))
        case .media:
            Label("chat_pin_preview_media".localized, systemImage: "photo.on.rectangle")
                .font(.system(size: 13, weight: .semibold))
        case .contact(let name, _):
            Label(name, systemImage: "person.fill")
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
        case .missedVoiceCall, .missedVideoCall, .pinNotification:
            Text(message.text)
                .font(.system(size: 13, weight: .semibold))
        }
    }

    // MARK: - Emoji reaction bar

    private var emojiBar: some View {
        HStack(spacing: 8) {
            ForEach(quickReactions, id: \.self) { emoji in
                Button {
                    onReact?(emoji)
                    onDismiss()
                } label: {
                    Text(emoji)
                        .font(.system(size: 24))
                }
            }

            Button {
                showEmojiPicker = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.appText)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(AppColor.chatReactPlus))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(AppColor.chatMyBubble))
        .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
    }

    // MARK: - Menu cards

    private var fullMenuCard: some View {
        buildCard(actions: ChatContextAction.allCases)
    }

    private func buildCard(actions: [ChatContextAction]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(actions.enumerated()), id: \.element) { index, action in
                menuRow(action: action)
                if index < actions.count - 1 {
                    Rectangle()
                        .fill(.appText.opacity(0.1))
                        .frame(height: 1)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(AppColor.chatMyBubble)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 4)
        )
    }

    private func menuRow(action: ChatContextAction) -> some View {
        let titleKey: String
        let iconName: String
        switch action {
        case .star:
            titleKey = message.isStarred ? "chat_ctx_unstar" : "chat_ctx_star"
            iconName = message.isStarred ? "star.slash" : "star"
        case .pin:
            titleKey = message.isPinned ? "chat_ctx_unpin" : "chat_ctx_pin"
            iconName = message.isPinned ? "pin.slash" : "pin"
        default:
            titleKey = action.titleKey
            iconName = action.icon
        }

        return Button {
            onAction(action)
            onDismiss()
        } label: {
            HStack {
                Text(titleKey.localized)
                    .font(.system(size: 14))
                    .foregroundStyle(action.isDestructive ? AppColor.chatDeleteMenu : .appText)
                Spacer()
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(action.isDestructive ? AppColor.chatDeleteMenu : .appText)
            }
            .padding(.horizontal, 8)
            .frame(height: 40)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
