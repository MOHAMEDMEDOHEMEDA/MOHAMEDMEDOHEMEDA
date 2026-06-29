//
//  ChatMessagesPanel.swift
//  Binbon
//

import SwiftUI

extension ChatView {

    var messagesPanel: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.messages) { message in
                        ChatBubbleRow(
                            message: message,
                            onLongPress: { tapped in
                                withAnimation(.easeIn(duration: 0.15)) { contextMessage = tapped }
                            },
                            onEmojiTap: { tapped, y in
                                emojiAnchorY = y
                                withAnimation(.easeIn(duration: 0.15)) { emojiOnlyMessage = tapped }
                            },
                            isSelectionMode: isForwardMode || isDeleteMode,
                            isSelected: selectedMessageIds.contains(message.id),
                            onSelectionToggle: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if selectedMessageIds.contains(message.id) {
                                        selectedMessageIds.remove(message.id)
                                    } else {
                                        selectedMessageIds.insert(message.id)
                                    }
                                }
                            },
                            isHighlighted: highlightedMessageId == message.id,
                            participantName: viewModel.participantName,
                            onReply: { msg in
                                withAnimation(.easeOut(duration: 0.2)) { replyingTo = msg }
                            },
                            onReplyTap: { messageId in
                                scrollToMessageId = messageId
                                withAnimation(.easeIn(duration: 0.1)) { highlightedMessageId = messageId }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                    withAnimation(.easeOut(duration: 0.5)) { highlightedMessageId = nil }
                                }
                            }
                        )
                        .id(message.id)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .defaultScrollAnchor(.bottom)
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                if let last = viewModel.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let last = viewModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: scrollToMessageId) { _, id in
                if let id {
                    withAnimation { proxy.scrollTo(id, anchor: .center) }
                    scrollToMessageId = nil
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollContentBackground(.hidden)
    }
}
