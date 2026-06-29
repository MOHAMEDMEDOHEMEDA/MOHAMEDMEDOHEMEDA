//
//  ChatBubbleRow.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import AVFoundation
import AVKit
import CoreLocation
import MapKit
import QuickLook
import SwiftUI
import UIKit

// QLPreviewController is in QuickLook — keep the import even though
// no top-level QuickLook type is referenced directly in the file header.

struct ChatBubbleRow: View {

    let message: ChatMessage
    var onLongPress: ((ChatMessage) -> Void)? = nil
    var onEmojiTap: ((ChatMessage, CGFloat) -> Void)? = nil
    var isSelectionMode: Bool = false
    var isSelected: Bool = false
    var onSelectionToggle: (() -> Void)? = nil
    var isHighlighted: Bool = false
    var participantName: String = ""
    var onReply: ((ChatMessage) -> Void)? = nil
    var onReplyTap: ((UUID) -> Void)? = nil
    @State private var isPressing = false
    
    private var isMine: Bool { message.sender == .me }

    @State private var showViewer = false
    @State private var viewerStartIndex = 0
    @State private var viewerImages: [Data] = []
    @State private var videoPlayerURL: URL? = nil
    @State private var showContactDetail = false
    @State private var swipeOffset: CGFloat = 0
    @State private var replyTriggered = false

    var body: some View {
        if message.kind == .pinNotification {
            pinNotificationRow
        } else {
        VStack(spacing: 2) {
            if let daySeparator = message.daySeparator {
                Text(daySeparator)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.appText.opacity(0.55))
                    .padding(.vertical, 10)
            }

            ZStack(alignment: .leading) {
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.appText)
                    .opacity(Double(min(1, swipeOffset / 55)))
                    .scaleEffect(max(0.3, Double(swipeOffset / 55)))
                    .padding(.leading, 4)

                HStack(alignment: .center, spacing: 6) {
                    if isMine {
                        if isSelectionMode { selectionCircle }

                        bubble.overlay(alignment: bubbleLikeAlignment) {
                            if message.isLiked || message.reaction != nil {
                                likeBadge
                                .offset(x: isMine ? 4 : -4, y: 10)
                            }
                        }

                        if !isSelectionMode, message.kind == .text { emojiIcon }

                        Spacer(minLength: 20)
                    } else {
                        Spacer(minLength: 20)

                        if !isSelectionMode, message.kind == .text { emojiIcon }

                        bubble.overlay(alignment: bubbleLikeAlignment) {
                            if message.isLiked || message.reaction != nil {
                                likeBadge
                                .offset(x: isMine ? 4 : -4, y: 10)
                            }
                        }

                        if isSelectionMode { selectionCircle }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if isSelectionMode { onSelectionToggle?() }
                }
                .scaleEffect(isPressing ? 1.05 : 1)
                .offset(y: isPressing ? -4 : 0)
                .shadow(
                    color: .black.opacity(isPressing ? 0.2 : 0),
                    radius: isPressing ? 10 : 0
                )
                .animation(
                    .spring(response: 0.3, dampingFraction: 0.6),
                    value: isPressing
                )
                .onLongPressGesture(
                    minimumDuration: 0.4,
                    maximumDistance: 20,
                    pressing: { pressing in
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            isPressing = pressing
                        }
                    },
                    perform: {
                        UINotificationFeedbackGenerator()
                            .notificationOccurred(.success)

                        if !isSelectionMode {
                            onLongPress?(message)
                        }
                    }
                )
                .offset(x: swipeOffset)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        guard !isSelectionMode,
                              abs(value.translation.width) > abs(value.translation.height),
                              value.translation.width > 0 else { return }
                        let offset = min(70, value.translation.width * 0.7)
                        swipeOffset = offset
                        if offset >= 55 && !replyTriggered {
                            replyTriggered = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    .onEnded { _ in
                        if replyTriggered { onReply?(message) }
                        replyTriggered = false
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            swipeOffset = 0
                        }
                    }
            )
            
            if !isMine {
                HStack {
                    Spacer()
                    readReceiptDot
                }
                .padding(.top, (message.isLiked || message.reaction != nil) ? 10 : 0)
            }
        }
        .fullScreenCover(isPresented: $showViewer) {
            ChatImageViewerView(images: viewerImages, startIndex: viewerStartIndex, isPresented: $showViewer)
        }
        .fullScreenCover(isPresented: Binding(get: { videoPlayerURL != nil }, set: { if !$0 { videoPlayerURL = nil } })) {
            if let url = videoPlayerURL { AVPlayerFullscreenView(url: url) }
        }
        .fullScreenCover(isPresented: $showContactDetail) {
            if case .contact(let name, let phone) = message.kind {
                ChatContactDetailView(name: name, phone: phone)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isHighlighted ? Color.appText.opacity(0.18) : Color.clear)
        )
        .animation(.easeOut(duration: 0.6), value: isHighlighted)
        }
    }

    // MARK: - Pin notification row

    private var pinNotificationRow: some View {
        Text(message.text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.appText.opacity(0.75))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.appText.opacity(0.12))
            )
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 4)
    }

    // MARK: - Selection circle

    private var selectionCircle: some View {
        ZStack {
            if isSelected {
                Circle().fill(Color(hex: "0BE812"))
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.appText)
            } else {
                Circle().stroke(Color.appText.opacity(0.35), lineWidth: 1.5)
            }
        }
        .frame(width: 24, height: 24)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Emoji reaction picker icon
    
    private var emojiIcon: some View {
        Image(systemName: "face.smiling")
            .font(.system(size: 14))
            .foregroundStyle(.appText)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onEnded { value in onEmojiTap?(message, value.location.y) }
            )
    }
    
    // MARK: - Bubble content
    
    @ViewBuilder
    private var bubble: some View {
        switch message.kind {
        case .text:
            textBubble
        case .pinNotification:
            pinNotificationRow
        case .missedVoiceCall, .missedVideoCall:
            callBubble
        case .voice(let url, let samples, let duration):
            VoiceMessageBubble(url: url, samples: samples, duration: duration,
                               time: message.time, isMine: isMine, isStarred: message.isStarred)
        case .images(let items, let caption):
            imagesBubble(items, caption: caption)
        case .sticker(let emoji, let caption):
            stickerBubble(emoji: emoji, caption: caption)
        case .location(let lat, let lon, let name):
            LocationBubble(latitude: lat, longitude: lon, name: name,
                           time: message.time, isMine: isMine, isStarred: message.isStarred)
        case .document(let name, let size, let url):
            DocumentBubbleView(name: name, size: size, url: url,
                               time: message.time, isMine: isMine, isStarred: message.isStarred)
        case .audio(let url, let duration):
            VoiceMessageBubble(url: url, samples: [], duration: duration,
                               time: message.time, isMine: isMine, isStarred: message.isStarred)
        case .iconSticker(let named):
            iconStickerBubble(named: named)
        case .video(let url, let thumbnail, let caption):
            videoBubble(url: url, thumbnail: thumbnail, caption: caption)
        case .media(let images, let videoURL, let videoThumbnail, let caption):
            mediaBubble(images: images, videoURL: videoURL, videoThumbnail: videoThumbnail, caption: caption)
        case .contact(let name, let phone):
            contactBubble(name: name, phone: phone)
        }
    }

    // MARK: - Sticker bubble

    @ViewBuilder
    private func stickerBubble(emoji: String, caption: String) -> some View {
        VStack(alignment: isMine ? .trailing : .leading, spacing: 2) {
            Text(emoji)
                .font(.system(size: 72))
                .shadow(color: .black.opacity(0.15), radius: 4)
            if !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.appText.opacity(0.75))
                    .multilineTextAlignment(isMine ? .trailing : .leading)
            }
            HStack(spacing: 4) {
                if isMine { readReceiptDot }
                starBadge
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.65))
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.45, alignment: isMine ? .trailing : .leading)
    }

    // MARK: - Icon sticker bubble

    @ViewBuilder
    private func iconStickerBubble(named: String) -> some View {
        VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
            Image(named)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(AppColor.gold)
                .frame(width: 30, height: 30)
            HStack(spacing: 4) {
                if isMine { readReceiptDot }
                starBadge
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.65))
            }
        }
    }

    // MARK: - Video bubble

    @ViewBuilder
    private func videoBubble(url: URL, thumbnail: Data, caption: String) -> some View {
        let maxW = UIScreen.main.bounds.width * 0.65
        VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
            ZStack {
                if let uiImage = UIImage(data: thumbnail) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: maxW)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                        .frame(width: maxW, height: maxW * 0.56)
                }
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .offset(x: 2)
                    }
            }
            .onTapGesture { videoPlayerURL = url }

            if !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 13, weight: .semibold))
                    .multilineTextAlignment(isMine ? .trailing : .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(maxWidth: maxW, alignment: isMine ? .trailing : .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble)
                    )
            }

            HStack(spacing: 4) {
                if isMine { readReceiptDot }
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.65))
            }
        }
        .frame(maxWidth: maxW, alignment: isMine ? .trailing : .leading)
    }

    // MARK: - Text bubble

    private var textBubble: some View {
        let color: Color = isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble
        return VStack(alignment: .leading, spacing: 6) {
            if let quoted = message.replyTo {
                replyQuote(quoted)
            }
            Text(message.text)
                .font(.system(size: 13, weight: .bold))
                .multilineTextAlignment(isMine ? .leading : .trailing)

            HStack(spacing: 4) {
                starBadge
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.65))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(color))
        .overlay(alignment: isMine ? .bottomLeading : .bottomTrailing) {
            BubbleTail(isFromMe: isMine)
                .fill(color)
                .frame(width: 10, height: 15)
        }
    }

    private func replyQuote(_ info: ChatReplyInfo) -> some View {
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
        .contentShape(Rectangle())
        .onTapGesture { onReplyTap?(info.messageId) }
    }
    
    private var callBubble: some View {
        let isVideo = message.kind == .missedVideoCall
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(message.text)
                    .font(.system(size: 11, weight: .bold))
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.65))
            }
            
            Image(systemName: isVideo ? "video" : "phone.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble))
    }

    // MARK: - Images bubble

    @ViewBuilder
    private func imagesBubble(_ items: [Data], caption: String) -> some View {
        let maxW = UIScreen.main.bounds.width * 0.65
        VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
            imageTiles(items, maxWidth: maxW) { tappedIndex in
                viewerImages = items
                viewerStartIndex = tappedIndex
                showViewer = true
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 13, weight: .semibold))
                    .multilineTextAlignment(isMine ? .trailing : .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(maxWidth: maxW, alignment: isMine ? .trailing : .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble)
                    )
            }

            HStack(spacing: 4) {
                if isMine { readReceiptDot }
                starBadge
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.7))
            }
        }
        .frame(maxWidth: maxW, alignment: isMine ? .trailing : .leading)
    }

    @ViewBuilder
    private func imageTiles(_ items: [Data], maxWidth: CGFloat, onTap: @escaping (Int) -> Void) -> some View {
        let count = items.count
        if count == 1 {
            if let uiImage = UIImage(data: items[0]) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: maxWidth, maxHeight: 320)
                    .contentShape(Rectangle())
                    .onTapGesture { onTap(0) }
            }
        } else if count == 2 {
            HStack(spacing: 2) {
                singleImageCell(items[0]).frame(height: 140).clipped().onTapGesture { onTap(0) }
                singleImageCell(items[1]).frame(height: 140).clipped().onTapGesture { onTap(1) }
            }
            .frame(maxWidth: maxWidth)
        } else {
            // Odd total: show up to 5 tiles (pairs + full-width last).
            // Even total: show up to 4 tiles in pairs; overflow badge on the last tile.
            let isOdd = count % 2 == 1
            let visible = Array(items.prefix(isOdd ? 5 : 4))
            let overflow = count - visible.count
            let pairRows = visible.count / 2

            VStack(spacing: 2) {
                ForEach(0..<pairRows, id: \.self) { row in
                    let i0 = row * 2
                    let i1 = i0 + 1
                    // Overflow badge lands on the last right tile only for even layouts
                    let showBadge = !isOdd && row == pairRows - 1 && overflow > 0
                    HStack(spacing: 2) {
                        singleImageCell(visible[i0])
                            .frame(height: 100).clipped()
                            .onTapGesture { onTap(i0) }
                        ZStack {
                            singleImageCell(visible[i1]).frame(height: 100).clipped()
                            if showBadge {
                                Rectangle().fill(Color.black.opacity(0.5))
                                Text("+\(overflow)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 100)
                        .onTapGesture { onTap(i1) }
                    }
                }

                // Full-width last tile for odd counts
                if isOdd {
                    let last = visible.count - 1
                    ZStack {
                        singleImageCell(visible[last])
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .clipped()
                        if overflow > 0 {
                            Rectangle().fill(Color.black.opacity(0.5))
                            Text("+\(overflow)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .onTapGesture { onTap(last) }
                }
            }
            .frame(maxWidth: maxWidth)
        }
    }

    @ViewBuilder
    private func singleImageCell(_ data: Data) -> some View {
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Color.gray.opacity(0.3)
        }
    }

    // MARK: - Contact bubble

    @ViewBuilder
    private func contactBubble(name: String, phone: String) -> some View {
        VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
            HStack(spacing: 12) {
                Circle()
                    .fill(AppColor.gold.opacity(0.2))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColor.gold)
                    }
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.appText)
                        .lineLimit(1)
                    if !phone.isEmpty {
                        Text(phone)
                            .font(.system(size: 11))
                            .foregroundStyle(.appText.opacity(0.7))
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble)
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.72)
            .contentShape(Rectangle())
            .onTapGesture { showContactDetail = true }

            HStack(spacing: 4) {
                if isMine { readReceiptDot }
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.65))
            }
        }
    }

    // MARK: - Media bubble (images + video in one message)

    @ViewBuilder
    private func mediaBubble(images: [Data], videoURL: URL, videoThumbnail: Data, caption: String) -> some View {
        let maxW = UIScreen.main.bounds.width * 0.65
        VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
            imageTiles(images, maxWidth: maxW) { tappedIndex in
                viewerImages = images
                viewerStartIndex = tappedIndex
                showViewer = true
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            ZStack {
                if let uiImage = UIImage(data: videoThumbnail) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: maxW)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                        .frame(width: maxW, height: maxW * 0.56)
                }
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .offset(x: 2)
                    }
            }
            .onTapGesture { videoPlayerURL = videoURL }

            if !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 13, weight: .semibold))
                    .multilineTextAlignment(isMine ? .trailing : .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(maxWidth: maxW, alignment: isMine ? .trailing : .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble)
                    )
            }

            HStack(spacing: 4) {
                if isMine { readReceiptDot }
                starBadge
                Text(message.time)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.7))
            }
        }
        .frame(maxWidth: maxW, alignment: isMine ? .trailing : .leading)
    }

    // MARK: - Shared

    private var readReceiptDot: some View {
        Image("chat-check")
            .resizable()
            .frame(width: 14, height: 14)
    }

    @ViewBuilder
    private var starBadge: some View {
        if message.isStarred {
            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundStyle(.appText.opacity(0.65))
        }
    }
    
    // MARK: - Like badge
    
    private var bubbleLikeAlignment: Alignment {
        isMine ? .bottomLeading : .bottomTrailing
    }
    
    private var likeBadge: some View {
        Group {
            if let emoji = message.reaction {
                Text(emoji)
                    .font(.system(size: 12))
            } else {
                Image(systemName: "heart.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppColor.chatHartIcon)
            }
        }
        .padding(4)
        .background(Circle().fill(.appText))
    }
}

private struct BubbleTail: Shape {
    let isFromMe: Bool

    func path(in rect: CGRect) -> Path {
        var p = Path()

        if isFromMe {
            p.move(to: CGPoint(x: 0, y: 0))
            p.addLine(to: CGPoint(x: rect.width, y: rect.height))
            p.addLine(to: CGPoint(x: 0, y: rect.height))
        } else {
            p.move(to: CGPoint(x: rect.width, y: 0))
            p.addLine(to: CGPoint(x: rect.width, y: rect.height))
            p.addLine(to: CGPoint(x: 0, y: rect.height))
        }

        p.closeSubpath()
        return p
    }
}

// MARK: - Location bubble

private struct LocationBubble: View {
    let latitude: Double
    let longitude: Double
    let name: String
    let time: String
    let isMine: Bool
    var isStarred: Bool = false

    @State private var snapshot: UIImage? = nil
    @State private var showOptions = false

    private let bubbleWidth = UIScreen.main.bounds.width * 0.68

    var body: some View {
        VStack(alignment: isMine ? .trailing : .leading, spacing: 0) {
            ZStack {
                if let img = snapshot {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(hex: "2A2A2E")
                    ProgressView().tint(.white)
                }
            }
            .frame(width: bubbleWidth, height: 130)
            .clipped()

            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppColor.gold)
                    Text(name)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                        .foregroundStyle(.appText)
                }
                HStack(spacing: 3) {
                    if isMine {
                        HStack(spacing: -2) {
                            Image(systemName: "checkmark")
                            Image(systemName: "checkmark")
                        }
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                    }
                    if isStarred {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.appText.opacity(0.65))
                    }
                    Text(time)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.appText.opacity(0.7))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble)
        )
        .frame(width: bubbleWidth)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture { showOptions = true }
        .confirmationDialog("location_open_with".localized, isPresented: $showOptions, titleVisibility: .visible) {
            Button("open_in_apple_maps".localized) { openAppleMaps() }
            if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                Button("open_in_google_maps".localized) { openGoogleMaps() }
            }
            Button("cancel".localized, role: .cancel) {}
        }
        .task { snapshot = await makeMapSnapshot() }
    }

    private func openAppleMaps() {
        let q = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "maps://?ll=\(latitude),\(longitude)&q=\(q)") else { return }
        UIApplication.shared.open(url)
    }

    private func openGoogleMaps() {
        guard let url = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)") else { return }
        UIApplication.shared.open(url)
    }

    private func makeMapSnapshot() async -> UIImage? {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: coord, latitudinalMeters: 600, longitudinalMeters: 600)
        options.size = CGSize(width: bubbleWidth * UIScreen.main.scale, height: 260)
        options.scale = UIScreen.main.scale
        options.mapType = .standard
        guard let result = try? await MKMapSnapshotter(options: options).start() else { return nil }

        let renderer = UIGraphicsImageRenderer(size: result.image.size)
        return renderer.image { _ in
            result.image.draw(at: .zero)
            let pin = UIImage(systemName: "mappin.circle.fill")?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal)
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 28))
            let pt = result.point(for: coord)
            pin?.draw(in: CGRect(x: pt.x - 14, y: pt.y - 28, width: 28, height: 28))
        }
    }
}

// MARK: - Document bubble

private struct DocumentBubbleView: View {
    let name: String
    let size: String
    let url: URL
    let time: String
    let isMine: Bool
    var isStarred: Bool = false

    @State private var showPreview = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            fileIcon
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.appText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(size)
                    .font(.system(size: 11))
                    .foregroundStyle(.appText.opacity(0.65))
                HStack(spacing: 3) {
                    if isMine {
                        HStack(spacing: -2) {
                            Image(systemName: "checkmark")
                            Image(systemName: "checkmark")
                        }
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                    }
                    if isStarred {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.appText.opacity(0.65))
                    }
                    Text(time)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.appText.opacity(0.65))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble)
        )
        .frame(maxWidth: UIScreen.main.bounds.width * 0.72)
        .onTapGesture { showPreview = true }
        .sheet(isPresented: $showPreview) {
            QLPreviewWrapper(url: url).ignoresSafeArea()
        }
    }

    private var fileIcon: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "doc.fill")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.88))
            let ext = url.pathExtension.uppercased()
            if !ext.isEmpty {
                Text(ext)
                    .font(.system(size: 6, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 1.5)
                    .background(Capsule().fill(AppColor.gold))
            }
        }
    }
}

private struct QLPreviewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let vc = QLPreviewController()
        vc.dataSource = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    final class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as NSURL
        }
    }
}

// MARK: - Voice message bubble

private struct VoiceMessageBubble: View {
    let url: URL
    let samples: [CGFloat]
    let duration: Int
    let time: String
    let isMine: Bool
    var isStarred: Bool = false

    @State private var isPlaying = false
    @State private var progress: CGFloat = 0
    @State private var player: AVAudioPlayer? = nil
    @State private var playTimer: Timer? = nil

    private var durationText: String {
        let m = duration / 60
        let s = duration % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        HStack(spacing: 10) {
            Button { togglePlay() } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.appText)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(AppColor.gold.opacity(0.2)))
            }
            .buttonStyle(.plain)

            waveform
                .frame(height: 30)

            VStack(alignment: .trailing, spacing: 2) {
                Text(durationText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.8))
                HStack(spacing: 4) {
                    if isStarred {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.appText.opacity(0.65))
                    }
                    Text(time)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.appText.opacity(0.65))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isMine ? AppColor.chatMyBubble : AppColor.chatOtherBubble)
        )
        .frame(maxWidth: UIScreen.main.bounds.width * 0.72)
        .onDisappear { stopPlay() }
    }

    @ViewBuilder
    private var waveform: some View {
        let bars: [CGFloat] = samples.isEmpty
            ? (0..<24).map { _ in CGFloat.random(in: 0.15...0.85) }
            : samples
        GeometryReader { geo in
            HStack(alignment: .center, spacing: 2) {
                ForEach(Array(bars.enumerated()), id: \.offset) { idx, amp in
                    let barFraction = CGFloat(idx) / CGFloat(bars.count)
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(barFraction <= progress ? AppColor.gold : Color.appText.opacity(0.3))
                        .frame(width: 2.5, height: max(4, amp * geo.size.height))
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func togglePlay() {
        isPlaying ? stopPlay() : startPlay()
    }

    private func startPlay() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let p = try AVAudioPlayer(contentsOf: url)
            player = p
            p.play()
            isPlaying = true
            playTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                guard let p = player else { return }
                progress = p.duration > 0 ? CGFloat(p.currentTime / p.duration) : 0
                if !p.isPlaying {
                    isPlaying = false
                    progress = 0
                    playTimer?.invalidate()
                    playTimer = nil
                }
            }
        } catch {
            // Playback not available (e.g. invalid URL in mock data)
        }
    }

    private func stopPlay() {
        player?.stop()
        player = nil
        isPlaying = false
        progress = 0
        playTimer?.invalidate()
        playTimer = nil
    }
}

// MARK: - Full-screen video player

private struct AVPlayerFullscreenView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AVPlayerControllerView(url: url)
            .ignoresSafeArea()
    }
}

private struct AVPlayerControllerView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        let player = AVPlayer(url: url)
        vc.player = player
        player.play()
        return vc
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
