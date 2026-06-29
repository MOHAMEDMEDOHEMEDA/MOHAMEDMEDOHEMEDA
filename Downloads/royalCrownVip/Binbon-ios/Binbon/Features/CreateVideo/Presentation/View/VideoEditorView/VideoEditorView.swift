//
//  VideoEditorView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import SwiftUI

struct VideoEditorView: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    let videoURL: URL?
    let image: UIImage?
    let layout: VideoLayoutOption
    var onClose: () -> Void = {}
    var onNext: () -> Void = {}
    var onSaveDraft: () -> Void = {}
    var nextTitle: String? = nil
    var showStoryButton: Bool = true
    var showSettingsItem: Bool = true
    var showCaption: Bool = false

    enum BottomPanel { case none, filters, effects }

    @StateObject private var soundPlayer = AudioPreviewPlayer()
    @StateObject private var editorEffects = VideoEffectsState()
    @StateObject private var voice = VoiceOverRecorder()
    @StateObject private var clipPlayer = ClipPreviewPlayer()

    @State private var selectedID: UUID?
    @State private var editingItem: VideoOverlayItem?
    @State private var showText = false
    @State private var showStickers = false
    @State private var showVolume = false
    @State private var showVoice = false
    @State private var showTrim = false
    @State private var showSettings = false
    @State private var showSounds = false
    @State private var showShare = false
    @State private var showExitOptions = false
    @State private var bottomPanel: BottomPanel = .none
    @State private var isBaking = false
    @State private var showStoryEditor = false

    private var activeImage: UIImage? {
        viewModel.capturedPhoto ?? viewModel.primaryImage ?? image
    }

    private var isPhotoEditor: Bool {
        videoURL == nil && activeImage != nil
    }

    /// Read the safe area from the active window rather than the SwiftUI layout
    /// proxy: a freshly-presented `.fullScreenCover` reports a top inset of 0 on
    /// its first layout pass (the chrome only settled after a re-present), so the
    /// window's stable insets keep the top bar below the notch from the start.
    private var deviceSafeInsets: UIEdgeInsets {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow?.safeAreaInsets ?? .zero
    }

    var body: some View {
        ZStack {
            mediaBackground

            VideoEditorOverlayLayer(overlays: $viewModel.overlays,
                                    editable: true,
                                    selectedID: $selectedID,
                                    onEditText: { item in editingItem = item; showText = true })
            .allowsHitTesting(true)

            controls

            bottomPanels

            if showText {
                VideoEditorTextSheet(initial: editingItem,
                                     onCancel: { editingItem = nil; showText = false },
                                     onDone: { text, font, size, hex in
                                         applyText(text, font: font, size: size, hex: hex)
                                         editingItem = nil; showText = false
                                     })
                    .transition(.opacity)
                    .zIndex(60)
            }

            if isBaking { CreateVideoViewProcessingOverlay().zIndex(70) }

            if showExitOptions {
                VideoEditorExitSheet(
                    onSendToFriend: { showExitOptions = false; showShare = true },
                    onSaveDraft: { showExitOptions = false; onSaveDraft(); dismissEditor() },
                    onDiscard: { showExitOptions = false; dismissEditor() },
                    onCancel: { withAnimation { showExitOptions = false } }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .preferredColorScheme(.dark)
        .onAppear {
            try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try? AVAudioSession.sharedInstance().setActive(true)
            clipPlayer.load(videoURL)
            clipPlayer.setVolume(Float(viewModel.videoVolume))
            voice.loadExisting(viewModel.voiceoverURL, volume: Float(viewModel.voiceoverVolume))
            playSelectedSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { clipPlayer.play() }
        }
        .onDisappear { soundPlayer.stop(); voice.stop(); clipPlayer.stop() }
        .onChange(of: voice.volume) { viewModel.voiceoverVolume = Double(voice.volume) }
        .onChange(of: viewModel.selectedSound?.id) {
            playSelectedSound()
        }
        .onChange(of: editorEffects.filter) { editorEffects.panel = .none }
        .onChange(of: viewModel.soundVolume) { soundPlayer.setVolume(Float(viewModel.soundVolume)) }
        .onChange(of: showSettings) {
            if showSettings {
                clipPlayer.stop(); soundPlayer.stop(); voice.stop()
            } else {
                clipPlayer.play(); playSelectedSound()
            }
        }
        .onChange(of: viewModel.videoVolume) { clipPlayer.setVolume(Float(viewModel.videoVolume)) }

        .sheet(isPresented: $showStickers) {
            VideoEditorStickerPicker(onPick: { emoji in
                viewModel.overlays.append(VideoOverlayItem(kind: .sticker(emoji)))
                showStickers = false
            }, onClose: { showStickers = false })
            .localizedLayout()
        }
        .sheet(isPresented: $showSounds) {
            SoundsSheet(selected: $viewModel.selectedSound, onClose: { showSounds = false })
                .localizedLayout()
        }
        .sheet(isPresented: $showShare) {
            SendToSheet(onClose: { showShare = false })
                .localizedLayout()
        }
        .fullScreenCover(isPresented: $showSettings) {
            PostSettingsSheet(videoURL: videoURL,
                              image: activeImage,
                              onClose: { showSettings = false })
                .localizedLayout()
        }
        .fullScreenCover(isPresented: $showTrim) {
            if let url = viewModel.capturedVideoURL {
                VideoTrimView(url: url,
                              onClose: { showTrim = false },
                              onNext: { trimmed in viewModel.capturedVideoURL = trimmed; showTrim = false })
                .localizedLayout()
            }
        }
        .fullScreenCover(isPresented: $showStoryEditor) {
            StoryEditorView(
                draft: makeStoryDraft(),
                onClose: { showStoryEditor = false },
                onPublished: { draft in
                    applyStoryDraft(draft)
                    showStoryEditor = false
                }
            )
            .localizedLayout()
        }
    }

    // MARK: - Controls

    private var mediaBackground: some View {
        ZStack {
            Color.black
            CapturedVideoLayoutView(
                videoURL: videoURL,
                image: activeImage,
                layout: layout,
                externalPlayer: clipPlayer.player,
                photoScale: viewModel.photoScale,
                photoRotation: viewModel.photoRotation
            )
            CreateVideoViewFilterOverlay(
                filter: editorEffects.filter,
                effect: editorEffects.effect,
                beauty: editorEffects.beauty
            )
        }
        .ignoresSafeArea(edges: [.horizontal, .bottom])
        .allowsHitTesting(false)
        .contentShape(Rectangle())
        .onTapGesture { selectedID = nil }
    }

    private var controls: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Button(action: handleBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.35), in: Circle())
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer()

                Button { soundPlayer.stop(); showSounds = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "music.note").font(.system(size: 13, weight: .semibold))
                        Text(viewModel.selectedSound?.title ?? "add_sound".localized)
                            .font(.system(size: 13, weight: .medium)).lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .frame(maxWidth: 180)
                    .background(.black.opacity(0.4), in: Capsule())
                }
                .buttonStyle(.plain)

                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 12)
            .padding(.top, deviceSafeInsets.top + 8)

            HStack(alignment: .top) {
                if isPhotoEditor {
                    photoAdjustBar
                }
                Spacer()
                VideoEditorMenu(items: menuItems)
                    .padding(.trailing, 16)
            }
            .padding(.top, 20)

            Spacer()

            if showCaption { captionBar }
            bottomBar
        }
        .ignoresSafeArea()
        .zIndex(50)
        .allowsHitTesting(true)
    }

    private func handleBack() {
        if isPhotoEditor {
            dismissEditor()
            return
        }
        withAnimation { showExitOptions = true }
    }

    private func dismissEditor() {
        onClose()
    }

    private var menuItems: [VideoEditorMenu.Item] {
        var items: [VideoEditorMenu.Item] = []
        if showSettingsItem {
            items.append(.init(title: "".localized, icon: "gearshape") { showSettings = true })
        }
        items += [
            .init(title: "".localized,    icon: "square.and.arrow.up") { showShare = true },
            .init(title: "".localized,     icon: "rectangle.dashed") { showTrim = true },
            .init(title: "".localized,     icon: "textformat") { editingItem = nil; showText = true },
            .init(title: "".localized, icon: "face.smiling") { showStickers = true },
            .init(title: "".localized,  icon: "sparkles") { toggle(.effects) },
            .init(title: "".localized,     icon: "camera.filters") { toggle(.filters) },
            .init(title: "".localized,    icon: "mic.fill") { withAnimation { showVoice.toggle() } },
            .init(title: "".localized,      icon: "speaker.wave.2.fill") { withAnimation { showVolume.toggle() } }
        ]
        return items
    }

    @ViewBuilder private var bottomPanels: some View {
        VStack {
            Spacer()
            switch bottomPanel {
            case .filters: CreateVideoViewFilterCarousel(effects: editorEffects).padding(.bottom, 92)
            case .effects: CreateVideoViewEffectCarousel(effects: editorEffects).padding(.bottom, 92)
            case .none:    EmptyView()
            }
            if showVolume {
                VideoEditorVolumePanel(videoVolume: $viewModel.videoVolume,
                                       soundVolume: $viewModel.soundVolume,
                                       hasSound: viewModel.selectedSound != nil,
                                       onClose: { showVolume = false })
                    .padding(.bottom, 92)
            }
            if showVoice { voicePanel.padding(.bottom, 92) }
        }
        .allowsHitTesting(bottomPanel != .none || showVolume || showVoice)
    }

    private var voicePanel: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Button {
                    voice.toggle()
                    if voice.isRecording {
                        clipPlayer.setVolume(0)
                        soundPlayer.stop()
                    } else {
                        viewModel.voiceoverURL = voice.fileURL
                        clipPlayer.setVolume(Float(viewModel.videoVolume))
                        playSelectedSound()
                        voice.play()
                    }
                } label: {
                    ZStack {
                        Circle().stroke(.white, lineWidth: 3).frame(width: 48, height: 48)
                        RoundedRectangle(cornerRadius: voice.isRecording ? 4 : 19)
                            .fill(Color(hex: "E14554"))
                            .frame(width: voice.isRecording ? 20 : 38, height: voice.isRecording ? 20 : 38)
                    }
                }
                .buttonStyle(.plain)
                Text(voice.isRecording ? "ed_recording".localized : "ed_voiceover".localized)
                    .font(.system(size: 14, weight: .medium)).foregroundStyle(.white)
                Spacer()
                Button { showVoice = false } label: { Image(systemName: "xmark").foregroundStyle(.white) }
                    .buttonStyle(.plain)
            }

            if voice.fileURL != nil && !voice.isRecording {
                HStack(spacing: 12) {
                    Button { voice.togglePlayback() } label: {
                        Image(systemName: voice.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
                    Slider(value: $voice.volume, in: 0...1)
                    Text("\(Int(voice.volume * 100))%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 38, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private var captionBar: some View {
        HStack(spacing: 10) {
            TextField("chat_camera_add_desc".localized, text: $viewModel.caption)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(.white)
                .frame(maxWidth: .infinity)
            Image("composer-gallery")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 16)
        .frame(height: 46)
        .background(
            LinearGradient(
                colors: [Color(hex: "83489C"), Color(hex: "EB7048")],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 23)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            if showStoryButton {
                Button { showStoryEditor = true } label: {
                    HStack(spacing: 7) {
                        CreateVideoViewStoryAvatar(image: viewModel.thumbnailImage)
                        Text("your_story".localized)
                            .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(Color(hex: "262626"), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }

            Button(action: handleNext) {
                Text(nextTitle ?? "next".localized)
                    .font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(Color(hex: "E14554"), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, max(deviceSafeInsets.bottom, 8) + 8)
    }

    // MARK: - Photo zoom / rotate
    private var photoAdjustBar: some View {
        VStack(spacing: 12) {
            photoButton("plus.magnifyingglass") {
                viewModel.photoScale = min(4, viewModel.photoScale + 0.2)
            }
            photoButton("minus.magnifyingglass") {
                viewModel.photoScale = max(1, viewModel.photoScale - 0.2)
            }
            photoButton("arrow.clockwise") {
                viewModel.photoRotation += .degrees(90)
            }
        }
        .padding(.leading, 16)
    }

    private func photoButton(_ icon: String, _ action: @escaping () -> Void) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.2)) { action() } } label: {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.black.opacity(0.4), in: Circle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers
    private func toggle(_ panel: BottomPanel) {
        withAnimation { bottomPanel = (bottomPanel == panel) ? .none : panel }
    }

    private func applyText(_ text: String, font: OverlayFont, size: CGFloat, hex: String) {
        let kind = VideoOverlayItem.Kind.text(text, fontName: font.rawValue, fontSize: size, colorHex: hex)
        if let editingItem, let index = viewModel.overlays.firstIndex(where: { $0.id == editingItem.id }) {
            viewModel.overlays[index].kind = kind
        } else {
            viewModel.overlays.append(VideoOverlayItem(kind: kind))
        }
    }

    private func playSelectedSound() {
        soundPlayer.play(fileName: viewModel.selectedSound?.fileName, volume: Float(viewModel.soundVolume),
                         mixWithCapture: false)
    }

    private func handleNext() {
        let needsVideoBake = editorEffects.needsExport
        let needsAudioMix = viewModel.voiceoverURL != nil
            || viewModel.selectedSound?.fileName != nil
            || viewModel.videoVolume < 1
        // Use the trimmed URL if the user trimmed the clip, otherwise fall back to the original.
        let activeVideoURL = viewModel.capturedVideoURL ?? videoURL
        guard let start = activeVideoURL, needsVideoBake || needsAudioMix else {
            // Photo path: bake filter + overlays into a UIImage before calling onNext.
            if isPhotoEditor, let photo = activeImage {
                viewModel.bakedPhoto = bakePhoto(photo)
            }
            viewModel.bakedVideoURL = activeVideoURL
            onNext(); return
        }

        isBaking = true
        soundPlayer.stop()
        voice.stop()
        Task {
            var url = start
            if needsVideoBake {
                url = await VideoEffectsProcessor.process(
                    url: url,
                    filter: editorEffects.filter,
                    effect: editorEffects.effect,
                    beauty: editorEffects.beauty,
                    speed: editorEffects.speed)
            }
            if needsAudioMix {
                url = await VideoAudioMixer.mix(
                    videoURL: url,
                    originalVolume: Float(viewModel.videoVolume),
                    soundFileName: viewModel.selectedSound?.fileName,
                    soundVolume: Float(viewModel.soundVolume),
                    voiceoverURL: viewModel.voiceoverURL,
                    voiceoverVolume: Float(viewModel.voiceoverVolume))
            }
            await MainActor.run {
                viewModel.bakedVideoURL = url
                isBaking = false
                onNext()
            }
        }
    }
    
    private func makeStoryDraft() -> StoryDraft {
        StoryDraft(
            mediaImage: activeImage,
            mediaVideoURL: viewModel.bakedVideoURL ?? viewModel.capturedVideoURL ?? videoURL,
            overlays: viewModel.overlays.map { StoryOverlayMapper.from(video: $0) },
            soundFileName: viewModel.selectedSound?.fileName,
            filter: editorEffects.filter,
            photoScale: viewModel.photoScale,
            photoRotation: viewModel.photoRotation
        )
    }

    private func applyStoryDraft(_ draft: StoryDraft) {
        viewModel.photoScale = draft.photoScale
        viewModel.photoRotation = draft.photoRotation
        editorEffects.filter = draft.filter
        viewModel.overlays = draft.overlays.compactMap { StoryOverlayMapper.videoItem(from: $0) }
    }

    // MARK: - Photo baking

    /// Composites filter + overlays onto the photo at screen resolution.
    private func bakePhoto(_ photo: UIImage) -> UIImage {
        let size = UIScreen.main.bounds.size
        let content = PhotoBakeView(
            photo: photo,
            photoScale: viewModel.photoScale,
            photoRotation: viewModel.photoRotation,
            filter: editorEffects.filter,
            effect: editorEffects.effect,
            beauty: editorEffects.beauty,
            overlays: viewModel.overlays,
            size: size
        )
        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? photo
    }
}

// MARK: - Photo compositing view (used only by ImageRenderer)

private struct PhotoBakeView: View {
    let photo: UIImage
    let photoScale: CGFloat
    let photoRotation: Angle
    let filter: VideoFilter
    let effect: VideoEffect
    let beauty: Bool
    let overlays: [VideoOverlayItem]
    let size: CGSize

    var body: some View {
        ZStack {
            Color.black
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .scaleEffect(photoScale)
                .rotationEffect(photoRotation)
                .frame(width: size.width, height: size.height)
                .clipped()
            CreateVideoViewFilterOverlay(filter: filter, effect: effect, beauty: beauty)
            ForEach(overlays) { item in
                overlayContent(item)
                    .scaleEffect(item.scale)
                    .rotationEffect(item.rotation)
                    .offset(item.offset)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    @ViewBuilder
    private func overlayContent(_ item: VideoOverlayItem) -> some View {
        switch item.kind {
        case let .text(string, fontName, fontSize, colorHex):
            Text(string.isEmpty ? " " : string)
                .font((OverlayFont(rawValue: fontName) ?? .system).font(size: fontSize))
                .foregroundStyle(Color(hex: colorHex))
                .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
                .multilineTextAlignment(.center)
                .padding(6)
        case let .sticker(emoji):
            Text(emoji)
                .font(.system(size: 64))
                .padding(6)
        }
    }
}
