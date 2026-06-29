//
//  ChatView.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import AVFoundation
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ChatView: View {

    @Environment(\.router) var router
    @StateObject var viewModel: ChatViewModel
    @FocusState var composerFocused: Bool
    @State var showEmojiPicker = false
    @State var showStickerPicker = false
    @State var showPlusMenu = false
    @State var showDocumentPicker = false
    @State var showAudioPicker = false
    @State var showChatCamera = false
    @State var showLocationConfirm = false
    @State var showContactPicker = false
    @State var showGalleryFromPlusSheet = false
    @State var galleryPickerItems: [PhotosPickerItem] = []
    @State private var keyboardPadding: CGFloat = 0
    @State var isKeyboardOpen = false

    // Voice recording UX state
    @State var holdTimer: Timer? = nil
    @State var isHoldPending = false
    @State var isFingerDown = false
    @State var isShowingHint = false
    @State var isCancelling = false

    // Message interaction state
    @State var contextMessage: ChatMessage?
    @State var emojiOnlyMessage: ChatMessage?
    @State var replyingTo: ChatMessage?
    @State var isForwardMode = false
    @State var isDeleteMode = false
    @State var showDeleteConfirmation = false
    @State var selectedMessageIds: Set<UUID> = []
    @State var showPinPanel = false
    @State var pinTargetId: UUID?
    @State var pinTargetSender: ChatMessageSender = .me
    @State var showReportPanel = false
    @State var showForwardSheet = false
    @State var showSystemShareSheet = false
    @State var showCopyToast = false
    @State var scrollToMessageId: UUID?
    @State var highlightedMessageId: UUID?
    @State var emojiAnchorY: CGFloat = 0
    @State var shareItems: [Any] = []

    init(conversation: MessageConversation? = nil) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(conversation: conversation))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ChatWatermarkPattern()

            VStack(spacing: 0) {
                if isForwardMode || isDeleteMode { selectionHeader } else { header }
                if !isForwardMode, !isDeleteMode, viewModel.pinnedMessage != nil {
                    pinBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                messagesPanel

                if isDeleteMode && showDeleteConfirmation {
                    deleteConfirmationPanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if isDeleteMode {
                    deleteBottomBar
                } else if isForwardMode {
                    forwardBottomBar
                } else {
                    bottomComposerContent
                }
            }
            .padding(.bottom, keyboardPadding)
            .animation(.spring(response: 0.28, dampingFraction: 0.82), value: viewModel.recordingState)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isCancelling)
            .animation(.easeOut(duration: 0.25), value: keyboardPadding)
            .animation(.easeInOut(duration: 0.2), value: isDeleteMode)
            .animation(.easeInOut(duration: 0.2), value: isForwardMode)

            // Dismiss emoji/sticker picker on background tap
            if showEmojiPicker || showStickerPicker {
                VStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                showEmojiPicker = false
                                showStickerPicker = false
                            }
                        }
                    Spacer()
                        .frame(height: showEmojiPicker ? 400 : 380)
                }
                .ignoresSafeArea()
            }

            // Plus sheet overlay — slides up from the bottom edge
            if showPlusMenu {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showPlusMenu = false }
                    }
                    .transition(.opacity)
                    .zIndex(20)

                VStack(spacing: 0) {
                    Spacer()
                    ComposerPlusMenu { action in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showPlusMenu = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { handlePlusAction(action) }
                    }
                }
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
                .zIndex(21)
            }

            // Voice lock indicator while dragging up
            if viewModel.recordingState == .recording && viewModel.recordingDragOffset.height < -10 {
                VoiceLockIndicator(dragY: viewModel.recordingDragOffset.height)
                    .padding(.trailing, 16)
                    .padding(.bottom, 66)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }

            // Report panel
            if showReportPanel {
                VStack {
                    Spacer()
                    reportPanel
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(50)
            }

            // Pin duration panel
            if showPinPanel {
                VStack {
                    Spacer()
                    pinDurationPanel
                }
                .ignoresSafeArea(edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(50)
            }

            // Copy success toast — centered, just above the composer bar
            if showCopyToast {
                VStack {
                    Spacer()
                    copyToastPill
                }
                .frame(maxWidth: .infinity)
                .zIndex(50)
            }

            // Long-press context menu overlay
            if let msg = contextMessage {
                ChatMessageContextMenu(
                    message: msg,
                    participantName: viewModel.participantName,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.2)) { contextMessage = nil }
                    },
                    onAction: { action in
                        contextMessage = nil
                        handleContextAction(action, for: msg)
                    },
                    onReact: { emoji in
                        viewModel.setReaction(emoji, for: msg.id)
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }

            // Emoji-icon tap — show quick reaction bar only
            if let msg = emojiOnlyMessage {
                ChatMessageContextMenu(
                    message: msg,
                    anchorY: emojiAnchorY,
                    onDismiss: {
                        withAnimation(.easeOut(duration: 0.2)) { emojiOnlyMessage = nil }
                    },
                    onAction: { action in
                        emojiOnlyMessage = nil
                        handleContextAction(action, for: msg)
                    },
                    onReact: { emoji in
                        viewModel.setReaction(emoji, for: msg.id)
                        emojiOnlyMessage = nil
                    },
                    showMenuItems: false
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showPlusMenu)
        .animation(.easeOut(duration: 0.2), value: contextMessage != nil)
        .animation(.easeOut(duration: 0.2), value: emojiOnlyMessage != nil)
        .animation(.spring(duration: 0.3), value: showReportPanel)
        .animation(.spring(duration: 0.3), value: showPinPanel)
        .animation(.spring(duration: 0.3), value: showCopyToast)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.load() }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
            guard let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            let safeBottom = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: \.isKeyWindow)?.safeAreaInsets.bottom ?? 0
            withAnimation(.easeOut(duration: duration)) {
                keyboardPadding = max(0, frame.height - safeBottom)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notif in
            let duration = (notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            withAnimation(.easeOut(duration: duration)) {
                keyboardPadding = 0
            }
        }
        .onChange(of: composerFocused) { _, focused in
            if focused { showEmojiPicker = false; showStickerPicker = false }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isKeyboardOpen = focused
            }
        }
        .onChange(of: showEmojiPicker) { _, open in
            if open { showStickerPicker = false }
        }
        .onChange(of: viewModel.recordingState) { _, state in
            if state == .idle {
                holdTimer?.invalidate()
                holdTimer = nil
                isHoldPending = false
                isFingerDown = false
            }
        }
        .background(DocumentPickerHost(isPresented: $showDocumentPicker, types: [.item]) { url in
            handleDocumentURL(url)
        })
        .background(DocumentPickerHost(isPresented: $showAudioPicker, types: [.audio]) { url in
            handleAudioURL(url)
        })
        .confirmPopup(
            isPresented: $showLocationConfirm,
            title: "share_location_title".localized,
            confirmTitle: "share_location_confirm".localized,
            onConfirm: { viewModel.sendLocation() }
        )
        .fullScreenCover(isPresented: $showChatCamera) {
            ChatCameraView(isPresented: $showChatCamera) { result in
                switch result {
                case .photo(let image, let caption):
                    viewModel.sendCapturedImage(image, caption: caption)
                case .video(let url, let thumbnail, let caption):
                    viewModel.sendVideo(url: url, thumbnail: thumbnail, caption: caption)
                }
            }
        }
        .photosPicker(
            isPresented: $showGalleryFromPlusSheet,
            selection: $galleryPickerItems,
            maxSelectionCount: 10,
            matching: .any(of: [.images, .videos])
        )
        .background(ContactPickerHost(isPresented: $showContactPicker) { name, phone in
            viewModel.sendContact(name: name, phone: phone)
        })
    }
}

#Preview {
    ChatView(conversation: MessageConversation.samples.first)
        .environment(\.router, AppRouter.shared)
}
