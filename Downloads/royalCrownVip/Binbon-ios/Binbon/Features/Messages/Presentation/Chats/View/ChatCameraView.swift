//
//  ChatCameraView.swift
//  Binbon
//

import AVFoundation
import AVKit
import Photos
import PhotosUI
import SwiftUI
import UIKit

// MARK: - Capture result passed to the caller

enum ChatCameraCaptureResult {
    case photo(UIImage, caption: String)
    case video(url: URL, thumbnail: Data, caption: String)
}

// MARK: - Mode

private enum ChatCameraMode: CaseIterable {
    case video, photo

    var titleKey: String {
        switch self {
        case .video: return "chat_camera_video"
        case .photo: return "chat_camera_photo"
        }
    }
}

// MARK: - Main view

struct ChatCameraView: View {

    @Binding var isPresented: Bool
    let onSend: (ChatCameraCaptureResult) -> Void

    @StateObject private var camera = CameraManager()
    @StateObject private var effects = VideoEffectsState()
    @StateObject private var editorViewModel = CreateVideoViewModel()

    @State private var mode: ChatCameraMode = .video
    @State private var capturedPhoto: UIImage?
    @State private var capturedVideoURL: URL?
    @State private var isProcessing = false

    // Hold-to-record tracking
    @State private var zoom: CGFloat = 1
    @State private var recordZoomBase: CGFloat = 1
    @State private var isHoldingRecord = false
    @State private var isLocked = false
    @State private var lockArmed = false

    // Gallery picker
    @State private var galleryItems: [PhotosPickerItem] = []
    @State private var galleryThumbnail: UIImage?

    // Front-flash brightness hack
    @State private var savedBrightness = UIScreen.main.brightness

    private var frontFlashActive: Bool {
        camera.flashEnabled && camera.position == .front && camera.isRecording
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            cameraBackground
            CreateVideoViewFilterOverlay(filter: effects.filter, beauty: effects.beauty)
            if frontFlashActive { CreateVideoViewFrontFlashOverlay() }
            if isProcessing { CreateVideoViewProcessingOverlay() }
            chrome
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .task {
            UIApplication.shared.isIdleTimerDisabled = true
            await camera.start()
            await loadGalleryThumbnail()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            camera.stop()
        }
        .onChange(of: camera.isRecording) { _, recording in
            if !recording { isLocked = false; lockArmed = false }
        }
        .onChange(of: frontFlashActive) { _, active in
            if active {
                savedBrightness = UIScreen.main.brightness
                UIScreen.main.brightness = 1.0
            } else {
                UIScreen.main.brightness = savedBrightness
            }
        }
        .onChange(of: galleryItems) { _, items in
            guard let item = items.first else { return }
            handleGalleryPick(item)
            galleryItems = []
        }
        // Full photo/video editor — presented after every capture
        .fullScreenCover(isPresented: $editorViewModel.showEditor) {
            VideoEditorView(
                viewModel: editorViewModel,
                videoURL: capturedVideoURL,
                image: capturedPhoto,
                layout: .single,
                onClose: {
                    editorViewModel.showEditor = false
                    resetCapture()
                },
                onNext: { handleEditorSend() },
                onSaveDraft: {
                    editorViewModel.showEditor = false
                    resetCapture()
                },
                nextTitle: "send".localized,
                showStoryButton: false,
                showSettingsItem: false,
                showCaption: true
            )
            .localizedLayout()
        }
    }

    // MARK: - Camera background

    @ViewBuilder
    private var cameraBackground: some View {
        Color.black.ignoresSafeArea()
        CameraPreview(session: camera.session)
            .ignoresSafeArea()
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let clamped = min(8, max(1, zoom * value))
                        camera.setZoom(clamped)
                    }
            )
    }

    // MARK: - Chrome overlay

    private var chrome: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.top, 60)
                .padding(.horizontal, 20)
            Spacer()
            recordingBottomPanel
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(alignment: .top) {
            camIconButton(camera.flashEnabled ? "bolt.fill" : "bolt.slash.fill") {
                camera.toggleFlash()
            }
            Spacer()
            camIconButton("xmark") { isPresented = false }
        }
    }

    // MARK: - Recording bottom panel

    private var recordingBottomPanel: some View {
        VStack(spacing: 24) {
            if effects.panel == .filters {
                CreateVideoViewFilterCarousel(effects: effects)
            }
            captureRow
            if !camera.isRecording {
                modeSelector
            }
        }
        .padding(.bottom, 36)
        .padding(.top, 16)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .top, endPoint: .bottom
            )
        )
        .animation(.easeInOut(duration: 0.2), value: camera.isRecording)
        .animation(.easeInOut(duration: 0.2), value: effects.panel)
    }

    // MARK: - Capture row

    private var captureRow: some View {
        ZStack {
            ChatCameraRecordButton(
                camera: camera,
                mode: mode,
                isHoldingRecord: $isHoldingRecord,
                isLocked: $isLocked,
                lockArmed: $lockArmed,
                zoom: $zoom,
                recordZoomBase: $recordZoomBase,
                onPhotoTap: { capturePhoto() },
                onLockedTap: { camera.stopRecording(); isLocked = false }
            )

            HStack {
                captureRowLeading
                Spacer()
                captureRowTrailing
            }
            .padding(.horizontal, 44)
        }
    }

    @ViewBuilder
    private var captureRowLeading: some View {
        if camera.isRecording && !isLocked {
            Image(systemName: lockArmed ? "lock.fill" : "lock.open")
                .font(.system(size: lockArmed ? 24 : 20, weight: .medium))
                .foregroundStyle(lockArmed ? AppColor.gold : .white.opacity(0.8))
                .frame(width: 44, height: 44)
                .background(Circle().fill(lockArmed ? Color.black.opacity(0.6) : Color.black.opacity(0.4)))
                .scaleEffect(lockArmed ? 1.2 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: lockArmed)
        } else if camera.hasSegments {
            Button { camera.reset() } label: {
                Image(systemName: "delete.left")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        } else {
            HStack(spacing: 14) {
                Button { camera.flipCamera() } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                Text("x1")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }

    @ViewBuilder
    private var captureRowTrailing: some View {
        if camera.hasSegments && !camera.isRecording {
            Button { Task { await confirmVideoCapture() } } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(Color(hex: "25D366")))
            }
            .buttonStyle(.plain)
        } else if !camera.isRecording {
            HStack(spacing: 14) {
                Button {
                    withAnimation { effects.togglePanel(.filters) }
                } label: {
                    Image(systemName: "camera.filters")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(effects.panel == .filters ? AppColor.gold : .white)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)

                galleryPickerButton
            }
        }
    }

    // MARK: - Mode selector

    private var modeSelector: some View {
        HStack(spacing: 28) {
            ForEach(ChatCameraMode.allCases, id: \.titleKey) { m in
                let selected = m == mode
                Text(m.titleKey.localized)
                    .font(.system(size: 13, weight: selected ? .bold : .medium))
                    .foregroundStyle(selected ? .white : .white.opacity(0.5))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) { mode = m }
                    }
            }
        }
    }

    // MARK: - Gallery button

    private var galleryPickerButton: some View {
        PhotosPicker(
            selection: $galleryItems,
            maxSelectionCount: 1,
            matching: .any(of: [.images, .videos])
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "4F4F4F"))
                if let thumb = galleryThumbnail {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "photo.on.rectangle")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .frame(width: 50, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(.white.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func capturePhoto() {
        camera.capturePhoto { image in
            guard let image else { return }
            let normalized = image.normalizedOrientation()
            capturedPhoto = normalized
            capturedVideoURL = nil
            openEditor(photo: normalized)
        }
    }

    private func confirmVideoCapture() async {
        isProcessing = true
        let url = await camera.mergeSegments()
        isProcessing = false
        guard let url else { return }
        capturedVideoURL = url
        capturedPhoto = nil
        openEditor(videoURL: url)
    }

    // Prepares the shared editorViewModel and triggers VideoEditorView presentation.
    private func openEditor(photo: UIImage? = nil, videoURL: URL? = nil) {
        if let photo {
            editorViewModel.presentPhotoEditor(with: photo)
        } else {
            editorViewModel.capturedPhoto = nil
            editorViewModel.capturedVideoURL = videoURL
            editorViewModel.photoScale = 1
            editorViewModel.photoRotation = .zero
            editorViewModel.overlays = []
            editorViewModel.layout = .single
            editorViewModel.showEditor = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                editorViewModel.showEditor = true
            }
        }
    }

    private func handleEditorSend() {
        let caption = editorViewModel.caption
        // bakedPhoto has filter + overlays composited; fall back to raw capture if baking wasn't needed
        if let photo = editorViewModel.bakedPhoto ?? editorViewModel.capturedPhoto ?? capturedPhoto {
            editorViewModel.bakedPhoto = nil
            onSend(.photo(photo, caption: caption))
            isPresented = false
        } else if let videoURL = editorViewModel.bakedVideoURL ?? capturedVideoURL {
            Task {
                let thumb = await generateThumbnail(for: videoURL) ?? Data()
                onSend(.video(url: videoURL, thumbnail: thumb, caption: caption))
                isPresented = false
            }
        }
    }

    private func resetCapture() {
        capturedPhoto = nil
        capturedVideoURL = nil
        camera.reset()
    }

    private func handleGalleryPick(_ item: PhotosPickerItem) {
        let isVideo = item.supportedContentTypes.contains { $0.conforms(to: .audiovisualContent) }
        if isVideo {
            Task {
                if let video = try? await item.loadTransferable(type: VideoFile.self) {
                    capturedVideoURL = video.url
                    capturedPhoto = nil
                    openEditor(videoURL: video.url)
                }
            }
        } else {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    capturedPhoto = image
                    capturedVideoURL = nil
                    openEditor(photo: image)
                }
            }
        }
    }

    private func loadGalleryThumbnail() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            let granted = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            guard granted == .authorized || granted == .limited else { return }
        } else {
            guard status == .authorized || status == .limited else { return }
        }
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 1
        let result = PHAsset.fetchAssets(with: options)
        guard let asset = result.firstObject else { return }

        // Use isSynchronous = true on a detached task to guarantee exactly one callback,
        // avoiding the double-resume crash that happens with async delivery modes.
        let image = await Task.detached(priority: .utility) {
            let reqOptions = PHImageRequestOptions()
            reqOptions.isSynchronous = true
            reqOptions.deliveryMode = .highQualityFormat
            reqOptions.isNetworkAccessAllowed = true
            var result: UIImage?
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: CGSize(width: 120, height: 120),
                contentMode: .aspectFill,
                options: reqOptions
            ) { img, _ in result = img }
            return result
        }.value
        if let image { galleryThumbnail = image }
    }

    private func generateThumbnail(for url: URL) async -> Data? {
        await withCheckedContinuation { cont in
            let gen = AVAssetImageGenerator(asset: AVURLAsset(url: url))
            gen.appliesPreferredTrackTransform = true
            gen.maximumSize = CGSize(width: 600, height: 600)
            gen.generateCGImageAsynchronously(for: CMTime(seconds: 0, preferredTimescale: 600)) { cg, _, _ in
                guard let cg else { cont.resume(returning: nil); return }
                cont.resume(returning: UIImage(cgImage: cg).jpegData(compressionQuality: 0.8))
            }
        }
    }

    private func camIconButton(_ sysName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: sysName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.black.opacity(0.35)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Record button

private struct ChatCameraRecordButton: View {

    @ObservedObject var camera: CameraManager
    let mode: ChatCameraMode
    @Binding var isHoldingRecord: Bool
    @Binding var isLocked: Bool
    @Binding var lockArmed: Bool
    @Binding var zoom: CGFloat
    @Binding var recordZoomBase: CGFloat
    let onPhotoTap: () -> Void
    let onLockedTap: () -> Void

    @State private var dragX: CGFloat = 0

    private let segGradient = AnyShapeStyle(
        LinearGradient(
            colors: [Color(hex: "FFAAB3"), Color(hex: "83489C")],
            startPoint: .leading, endPoint: .trailing
        )
    )

    private var active: Bool { camera.isRecording || camera.hasSegments }

    // Slide the button left as the user drags toward the lock icon; cap at -80pt.
    private var slideOffset: CGFloat {
        guard camera.isRecording, !isLocked else { return 0 }
        return max(-80, min(0, dragX))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    lockArmed || isLocked ? AnyShapeStyle(AppColor.gold) : AnyShapeStyle(Color.white.opacity(0.8)),
                    lineWidth: active ? 16 : 10
                )
                .frame(width: active ? 84 : 100, height: active ? 84 : 100)
                .animation(.easeInOut(duration: 0.2), value: lockArmed)
                .animation(.easeInOut(duration: 0.2), value: isLocked)

            if active {
                ForEach(Array(arcs.enumerated()), id: \.offset) { _, arc in
                    Circle()
                        .trim(from: arc.0, to: arc.1)
                        .stroke(segGradient, style: StrokeStyle(lineWidth: 6, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 84, height: 84)
                        .animation(.linear(duration: 0.3), value: arc.1)
                }
            }

            Circle()
                .fill(
                    active
                        ? AnyShapeStyle(lockArmed || isLocked ? AppColor.gold : Color(hex: "E14554"))
                        : AnyShapeStyle(LinearGradient(
                            colors: [Color(hex: "E2704A"), Color(hex: "8E4C9E")],
                            startPoint: .top, endPoint: .bottom
                        ))
                )
                .frame(width: active ? 68 : 100, height: active ? 68 : 100)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
                .animation(.easeInOut(duration: 0.2), value: lockArmed)
                .animation(.easeInOut(duration: 0.2), value: isLocked)

            // Center icon swaps from logo to lock when recording is locked.
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            } else {
                Image("record-binbon-logo")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: active ? 40 : 70, height: active ? 40 : 70)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .offset(x: slideOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: active)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: slideOffset)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isLocked)
        .contentShape(Circle())
        .gesture(recordGesture, including: isLocked ? .subviews : .all)
        .simultaneousGesture(TapGesture().onEnded {
            if mode == .photo {
                onPhotoTap()
            } else if isLocked {
                onLockedTap()
            }
        })
    }

    private var arcs: [(Double, Double)] {
        let total = max(1, Double(camera.maxSeconds))
        var result: [(Double, Double)] = []
        var cursor = 0.0
        for dur in camera.segmentDurations {
            let end = min(1, cursor + dur / total)
            result.append((cursor, end))
            cursor = end
        }
        if camera.isRecording {
            let end = min(1, cursor + camera.recordingElapsed / total)
            result.append((cursor, end))
        }
        return result
    }

    private var recordGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                guard mode == .video, case .second(true, let drag) = value else { return }
                if !isHoldingRecord {
                    isHoldingRecord = true
                    recordZoomBase = zoom
                    camera.startRecording()
                }
                if let drag {
                    let dragUp = -drag.translation.height
                    let newZoom = min(5, max(1, recordZoomBase + dragUp / 120))
                    zoom = newZoom
                    camera.setZoom(newZoom)
                    dragX = drag.translation.width
                    lockArmed = -drag.translation.width > 80
                }
            }
            .onEnded { _ in
                guard mode == .video else { return }
                isHoldingRecord = false
                dragX = 0
                if lockArmed {
                    lockArmed = false
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                        isLocked = true
                    }
                } else {
                    camera.stopRecording()
                }
            }
    }
}
