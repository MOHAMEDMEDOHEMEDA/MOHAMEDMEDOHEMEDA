//
//  ChatComposerBar.swift
//  Binbon
//

import AVFoundation
import PhotosUI
import SwiftUI

extension ChatView {

    var bottomComposerContent: some View {
        VStack(spacing: 0) {
            composerSection
            if showEmojiPicker && viewModel.recordingState == .idle {
                EmojiPickerPanel(composerText: $viewModel.composerText)
                    .frame(height: 400)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            if showStickerPicker && viewModel.recordingState == .idle {
                StickerPickerPanel { sticker in
                    viewModel.sendSticker(emoji: sticker.emoji, caption: sticker.caption)
                }
                .frame(height: 380)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showEmojiPicker)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showStickerPicker)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: viewModel.recordingState)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isCancelling)
    }

    @ViewBuilder
    var composerSection: some View {
        if isCancelling {
            TrashCancelAnimation()
                .padding(.horizontal, 12)
                .padding(.vertical, 20)
                .background(AppColor.chatHeaderGradient.ignoresSafeArea(edges: .bottom))
                .transition(.opacity)
        } else {
            switch viewModel.recordingState {
            case .idle:
                VStack(spacing: 0) {
                    if let msg = replyingTo {
                        replyPreview(for: msg)
                            .animation(.spring(response: 0.3, dampingFraction: 0.85), value: replyingTo != nil)
                    }
                    if !viewModel.pendingImages.isEmpty || viewModel.pendingVideo != nil {
                        pendingMediaStrip
                    }
                    normalComposerBar
                }
                .transition(.opacity)
            case .recording:
                VoiceRecordingBar(
                    viewModel: viewModel,
                    micGestureView: AnyView(holdMicIcon),
                    isFingerDown: isFingerDown
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 20)
                .background(AppColor.chatHeaderGradient.ignoresSafeArea(edges: .bottom))
                .transition(.opacity)
            case .locked:
                VoiceLockedBar(viewModel: viewModel)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 20)
                    .background(AppColor.chatHeaderGradient.ignoresSafeArea(edges: .bottom))
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
        }
    }

    var isTyping: Bool {
        composerFocused || showEmojiPicker || showStickerPicker || !viewModel.composerText.isEmpty
    }

    var showPaperplane: Bool {
        !viewModel.composerText.trimmingCharacters(in: .whitespaces).isEmpty ||
        !viewModel.pendingImages.isEmpty ||
        viewModel.pendingVideo != nil
    }

    var normalComposerBar: some View {
        HStack(spacing: 10) {
            if showPaperplane {
                Button {
                    send()
                    composerFocused = false
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(width: 26, height: 26)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .transition(.scale(scale: 0.3).combined(with: .opacity))
            }

            composerField

            composerIconButton(image: Image("composer-sticker"), tinted: showStickerPicker) {
                composerFocused = false
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    showStickerPicker.toggle()
                    if showStickerPicker { showEmojiPicker = false }
                }
            }

            startRecordMicIcon

            HStack(spacing: 10) {
                galleryIcon
                composerIconButton(image: Image("composer-camera")) { showChatCamera = true }
                composerIconButton(image: Image("composer-plus")) {
                    composerFocused = false
                    showEmojiPicker = false
                    showStickerPicker = false
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showPlusMenu = true }
                }
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
        .padding(.horizontal, 15)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(AppColor.chatHeaderGradient.ignoresSafeArea(edges: .bottom))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isKeyboardOpen)
        .animation(.spring(response: 0.22, dampingFraction: 0.75), value: showPaperplane)
    }

    func composerIconButton(
        image: Image,
        tinted: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(tinted ? AnyShapeStyle(AppColor.gold) : AnyShapeStyle(.appText.opacity(0.85)))
                .frame(width: 26, height: 26)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var galleryIcon: some View {
        PhotosPicker(
            selection: $galleryPickerItems,
            maxSelectionCount: 10,
            matching: .any(of: [.images, .videos])
        ) {
            Image("composer-gallery")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onChange(of: galleryPickerItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                var images: [Data] = []
                var pickedVideoURL: URL? = nil
                for item in items {
                    let isVideo = item.supportedContentTypes
                        .contains { $0.conforms(to: .audiovisualContent) }
                    if isVideo, pickedVideoURL == nil {
                        if let video = try? await item.loadTransferable(type: VideoFile.self) {
                            pickedVideoURL = video.url
                        }
                    } else if !isVideo, let d = try? await item.loadTransferable(type: Data.self) {
                        images.append(d)
                    }
                }
                galleryPickerItems = []
                if !images.isEmpty {
                    viewModel.pendingImages = images
                    composerFocused = true
                }
                if let url = pickedVideoURL {
                    let thumb = await generateThumbnail(for: url) ?? Data()
                    viewModel.pendingVideo = (url: url, thumbnail: thumb)
                    composerFocused = true
                }
            }
        }
    }

    func generateThumbnail(for url: URL) async -> Data? {
        await withCheckedContinuation { cont in
            let asset = AVURLAsset(url: url)
            let gen = AVAssetImageGenerator(asset: asset)
            gen.appliesPreferredTrackTransform = true
            gen.maximumSize = CGSize(width: 600, height: 600)
            gen.generateCGImageAsynchronously(for: CMTime(seconds: 0, preferredTimescale: 600)) { cgImage, _, _ in
                guard let cgImage else { cont.resume(returning: nil); return }
                cont.resume(returning: UIImage(cgImage: cgImage).jpegData(compressionQuality: 0.8))
            }
        }
    }

    var pendingMediaStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<viewModel.pendingImages.count, id: \.self) { i in
                    if let img = UIImage(data: viewModel.pendingImages[i]) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                if let video = viewModel.pendingVideo, let img = UIImage(data: video.thumbnail) {
                    ZStack {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .frame(width: 60, height: 60)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            viewModel.pendingVideo = nil
                        }
                    }
                }
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        viewModel.pendingImages = []
                        viewModel.pendingVideo = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.black.opacity(0.25))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    var composerField: some View {
        HStack(spacing: 8) {
            Button {
                composerFocused = false
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    showEmojiPicker.toggle()
                }
            } label: {
                Image(systemName: "face.smiling")
                    .font(.system(size: 16))
                    .foregroundStyle(showEmojiPicker ? AnyShapeStyle(AppColor.gold) : AnyShapeStyle(.appText))
            }
            .buttonStyle(.plain)

            TextField(
                "",
                text: $viewModel.composerText,
                prompt: Text("chat_message_placeholder".localized)
                    .foregroundColor(.appText)
                    .font(.system(size: 14, weight: .semibold))
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.appText)
            .focused($composerFocused)
            .onSubmit {
                if showPaperplane {
                    send()
                    composerFocused = false
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Capsule().fill(.appText.opacity(0.14)))
    }
}
