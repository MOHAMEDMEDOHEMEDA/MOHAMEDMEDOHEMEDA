//
//  CreateVideoView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import Combine
import SwiftUI
import PhotosUI

struct CreateVideoView: View {

    @Environment(\.router) private var router
    @StateObject private var viewModel = CreateVideoViewModel()
    @StateObject private var camera = CameraManager()
    @StateObject private var effects = VideoEffectsState()
    @StateObject private var soundPlayer = AudioPreviewPlayer()

    var onClose: (() -> Void)? = nil

    @State private var zoom: CGFloat = 1
    @State private var zoomBase: CGFloat = 1
    @State private var showDurations = false
    @State private var showLayouts = false
    @State private var showTextComposer = false

    @State private var countdownValue: Int?
    @State private var countdownTask: Task<Void, Never>?
    @State private var isProcessingEffects = false
    @State private var savedBrightness = UIScreen.main.brightness

    private var frontFlashActive: Bool {
        camera.flashEnabled && camera.position == .front && camera.isRecording
    }

    @State private var recordZoomBase: CGFloat = 1
    @State private var isHoldingRecord = false
    @State private var isLocked = false
    @State private var lockArmed = false

    @State private var overlayOffset: CGSize = .zero
    @State private var overlayOffsetBase: CGSize = .zero
    @State private var overlayScale: CGFloat = 1
    @State private var overlayScaleBase: CGFloat = 1
    @State private var overlayRotation: Angle = .zero
    @State private var overlayRotationBase: Angle = .zero

    @State private var screenSize: CGSize = .zero
    @State private var isDraggingOverlay = false
    @State private var isOverTrash = false

    private let durations: [(String, Int)] = [("10m", 600), ("60s", 60), ("15s", 15)]

    private let controlTint: Color = .white
    private let chipBackground = Color(hex: "4F4F4F")

    var body: some View {
        ZStack {
            CreateVideoViewBackground(viewModel: viewModel,
                                      camera: camera,
                                      zoom: $zoom,
                                      zoomBase: $zoomBase)
            .opacity(viewModel.showEditor ? 0 : 1)
            .allowsHitTesting(!viewModel.showEditor)

            CreateVideoViewFilterOverlay(filter: effects.filter,
                                         effect: effects.effect,
                                         beauty: effects.beauty)

            if frontFlashActive {
                CreateVideoViewFrontFlashOverlay()
            }

            if !viewModel.showEditor {
                CreateVideoViewImageOverlay(viewModel: viewModel,
                                            overlayOffset: $overlayOffset,
                                            overlayOffsetBase: $overlayOffsetBase,
                                            overlayScale: $overlayScale,
                                            overlayScaleBase: $overlayScaleBase,
                                            overlayRotation: $overlayRotation,
                                            overlayRotationBase: $overlayRotationBase,
                                            screenSize: $screenSize,
                                            isDraggingOverlay: $isDraggingOverlay,
                                            isOverTrash: $isOverTrash)
            }

            if !viewModel.showEditor {
                createChrome
            }

            CreateVideoViewTrashZone(isDraggingOverlay: isDraggingOverlay, isOverTrash: isOverTrash)

            if let countdownValue {
                CreateVideoViewCountdownOverlay(value: countdownValue)
            }

            if isProcessingEffects {
                CreateVideoViewProcessingOverlay()
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { screenSize = proxy.size }
                    .onChange(of: proxy.size) { screenSize = proxy.size }
            }
        )
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .task {
            UIApplication.shared.isIdleTimerDisabled = true
            await camera.start()
            await viewModel.loadLastGalleryImage()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            camera.stop()
        }
        .onChange(of: viewModel.pickerItems) {
            Task { await viewModel.loadPickedImages() }
        }
        .onChange(of: viewModel.hasSelectedImage) {
            overlayOffset = .zero; overlayOffsetBase = .zero
            overlayScale = 1; overlayScaleBase = 1
            overlayRotation = .zero; overlayRotationBase = .zero
        }
        .onChange(of: zoom) { camera.setZoom(zoom) }
        .onChange(of: camera.isRecording) {
            if camera.isRecording {
                if camera.isFlipping {
                    camera.isFlipping = false
                } else {
                    soundPlayer.play(fileName: viewModel.selectedSound?.fileName)
                }
            } else if !camera.isFlipping {
                isLocked = false
                soundPlayer.stop()
            }
        }
        .onChange(of: viewModel.selectedSound?.id) {
            camera.isMuted = viewModel.selectedSound != nil
        }
        .onChange(of: viewModel.showEditor) {
            if viewModel.showEditor {
                soundPlayer.stop()
                camera.stop()
            } else {
                Task { await camera.start() }
            }
        }
        .onChange(of: frontFlashActive) {
            if frontFlashActive {
                savedBrightness = UIScreen.main.brightness
                UIScreen.main.brightness = 1.0
            } else {
                UIScreen.main.brightness = savedBrightness
            }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            SendToSheet(onClose: { viewModel.showShareSheet = false })
                .localizedLayout()
        }
        .sheet(isPresented: $viewModel.showSounds) {
            SoundsSheet(selected: $viewModel.selectedSound,
                        onClose: { viewModel.showSounds = false })
                .localizedLayout()
        }
        .fullScreenCover(isPresented: $viewModel.showTrim) {
            if let url = viewModel.capturedVideoURL {
                VideoTrimView(
                    url: url,
                    onClose: { viewModel.showTrim = false },
                    onNext: { trimmedURL in
                        viewModel.capturedVideoURL = trimmedURL
                        viewModel.showTrim = false
                    }
                )
                .localizedLayout()
            }
        }
        .fullScreenCover(isPresented: $showTextComposer) {
            TextPostComposerView(
                onClose: { showTextComposer = false },
                onNext: { image in
                    showTextComposer = false
                    viewModel.presentPhotoEditor(with: image)
                }
            )
            .localizedLayout()
        }
        .fullScreenCover(isPresented: $viewModel.showEditor) {
            VideoEditorView(
                viewModel: viewModel,
                videoURL: viewModel.capturedVideoURL,
                image: viewModel.capturedPhoto ?? viewModel.primaryImage,
                layout: viewModel.layout,
                onClose: { resetCaptureToCamera() },
                onNext: {
                    viewModel.showEditor = false
                    viewModel.showPostDetails = true
                },
                onSaveDraft: { resetCaptureToCamera() }
            )
            .localizedLayout()
            .background(Color.black)
        }
        .fullScreenCover(isPresented: $viewModel.showPostDetails) {
            PostDetailsView(
                videoURL: viewModel.bakedVideoURL ?? viewModel.capturedVideoURL,
                image: viewModel.capturedPhoto ?? viewModel.primaryImage,
                layout: viewModel.layout,
                overlays: viewModel.overlays,
                photoScale: viewModel.photoScale,
                photoRotation: viewModel.photoRotation,
                onClose: { reopenEditorFromPostDetails() }
            )
            .localizedLayout()
        }
    }

    private var createChrome: some View {
        VStack(spacing: 0) {
            if !camera.isRecording {
                CreateVideoViewTopBar(viewModel: viewModel,
                                      camera: camera,
                                      effects: effects,
                                      showDurations: $showDurations,
                                      showLayouts: $showLayouts,
                                      controlTint: controlTint,
                                      onClose: handleClose)
                    .transition(.opacity)
            }
            Spacer()
            CreateVideoViewBottomPanel(viewModel: viewModel,
                                       camera: camera,
                                       effects: effects,
                                       showDurations: showDurations,
                                       showLayouts: showLayouts,
                                       recordedSeconds: camera.totalRecordedSeconds + camera.recordingSeconds,
                                       recordedProgress: 0,
                                       durations: durations,
                                       controlTint: controlTint,
                                       chipBackground: chipBackground,
                                       onRecordTap: handleRecordTap,
                                       onDiscard: { camera.reset() },
                                       onConfirm: confirmCapture,
                                       zoom: $zoom,
                                       recordZoomBase: $recordZoomBase,
                                       isHoldingRecord: $isHoldingRecord,
                                       isLocked: $isLocked,
                                       lockArmed: $lockArmed)
        }
        .padding(.top, 8)
        .overlay(alignment: .top) {
            if !camera.isRecording && !camera.hasSegments && !viewModel.showPublish {
                CreateVideoViewAddSoundButton(title: viewModel.selectedSound?.title) {
                    viewModel.showSounds = true
                }
                .padding(.top, 12)
            }
        }
    }

    private func handleRecordTap() {
        if camera.isRecording {
            camera.stopRecording()
            isLocked = false
            return
        }
        if countdownValue != nil {
            cancelCountdown()
            return
        }
        camera.capturePhoto { image in
            guard let image else { return }
            viewModel.presentPhotoEditor(with: image.normalizedOrientation())
        }
    }

    private func confirmCapture() {
        isProcessingEffects = true
        Task {
            var result = await camera.mergeSegments() ?? camera.segments.first
            if let merged = result, effects.needsExport {
                result = await VideoEffectsProcessor.process(
                    url: merged,
                    filter: effects.filter,
                    effect: effects.effect,
                    beauty: effects.beauty,
                    speed: effects.speed)
            }
            if let final = result {
                _ = try? await AVURLAsset(url: final).load(.tracks, .duration)
            }
            await MainActor.run {
                isProcessingEffects = false
                guard let final = result else { return }
                viewModel.capturedVideoURL = final
                DispatchQueue.main.async {
                    viewModel.showEditor = true
                }
            }
        }
    }

    private func runCountdown(from value: Int) {
        countdownTask?.cancel()
        countdownTask = Task {
            var remaining = value
            while remaining > 0 {
                withAnimation { countdownValue = remaining }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                remaining -= 1
            }
            withAnimation { countdownValue = nil }
            camera.startRecording()
        }
    }

    private func resetCaptureToCamera() {
        viewModel.showEditor = false
        viewModel.showPostDetails = false
        viewModel.capturedVideoURL = nil
        viewModel.bakedVideoURL = nil
        viewModel.capturedPhoto = nil
        viewModel.pickerItems = []
        viewModel.clearSelectedImage()
        viewModel.photoScale = 1
        viewModel.photoRotation = .zero
        viewModel.overlays = []
        viewModel.selectedSound = nil
        viewModel.videoVolume = 1
        viewModel.soundVolume = 1
        viewModel.voiceoverURL = nil
        viewModel.voiceoverVolume = 1
        camera.reset()

    }

    private func reopenEditorFromPostDetails() {
        viewModel.showPostDetails = false
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            viewModel.showEditor = true
        }
    }

    private func cancelCountdown() {
        countdownTask?.cancel()
        countdownTask = nil
        withAnimation { countdownValue = nil }
    }

    private func handleClose() {
        if viewModel.showPublish {
            viewModel.showPublish = false
            viewModel.capturedVideoURL = nil
        } else if camera.hasSegments {
            camera.reset()
        } else if viewModel.hasSelectedImage {
            viewModel.clearSelectedImage()
        } else if let onClose {
            onClose()
        } else {
            router.back()
        }
    }
}

// MARK: - Preview
#Preview {
    CreateVideoView()
}
