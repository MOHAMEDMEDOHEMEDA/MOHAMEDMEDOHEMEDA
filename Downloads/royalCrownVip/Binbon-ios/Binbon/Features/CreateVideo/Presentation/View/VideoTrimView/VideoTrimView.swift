//
//  VideoTrimView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import Combine
import SwiftUI

struct VideoTrimView: View {

    let url: URL
    var onClose: () -> Void = {}
    var onNext: (_ trimmedURL: URL) -> Void = { _ in }

    @State private var duration: Double = 0
    @State private var startFraction: Double = 0
    @State private var endFraction: Double = 1
    @State private var playhead: Double = 0
    @State private var thumbnails: [UIImage] = []
    @State private var isProcessing = false

    private let stripHeight: CGFloat = 65
    private let handleWidth: CGFloat = 26

    private let ticker = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            LoopingPlayer(url: url)
                .ignoresSafeArea()
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: 0) {
                VideoTrimViewTopBar(isProcessing: isProcessing,
                                    onClose: onClose,
                                    onNext: process)
                Spacer()
                VStack(spacing: 14) {
                    VideoTrimViewTrimmer(startFraction: $startFraction,
                                         endFraction: $endFraction,
                                         playhead: playhead,
                                         thumbnails: thumbnails,
                                         stripHeight: stripHeight,
                                         handleWidth: handleWidth)
                    VideoTrimViewSelectedLabel(selectedSeconds: selectedSeconds)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
            }

            if isProcessing { VideoTrimViewProcessingCard() }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadDuration()
            await loadThumbnails()
        }
        .onReceive(ticker) { _ in
            guard duration > 0 else { return }
            playhead += 0.03 / duration
            if playhead > 1 { playhead = 0 }
        }
    }

    private var selectedSeconds: Double {
        max(0, (endFraction - startFraction) * duration)
    }

    // MARK: - Actions
    private func process() {
        guard !isProcessing else { return }
        withAnimation { isProcessing = true }
        Task {
            let trimmed = await exportTrimmed()
            await MainActor.run {
                isProcessing = false
                onNext(trimmed ?? url)
            }
        }
    }

    // MARK: - Loading
    private func loadDuration() async {
        let asset = AVURLAsset(url: url)
        if let cm = try? await asset.load(.duration) {
            duration = CMTimeGetSeconds(cm)
        }
    }

    private func loadThumbnails() async {
        let asset = AVURLAsset(url: url)
        guard let cm = try? await asset.load(.duration) else { return }
        let total = CMTimeGetSeconds(cm)
        guard total > 0 else { return }

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 120, height: 160)
        generator.requestedTimeToleranceBefore = .positiveInfinity
        generator.requestedTimeToleranceAfter = .positiveInfinity

        let count = 10
        var images: [UIImage] = []
        for i in 0..<count {
            let time = CMTime(seconds: total * Double(i) / Double(count), preferredTimescale: 600)
            if let result = try? await generator.image(at: time) {
                images.append(UIImage(cgImage: result.image))
            }
        }
        thumbnails = images
    }

    private func exportTrimmed() async -> URL? {
        let asset = AVURLAsset(url: url)
        guard duration > 0,
              let export = AVAssetExportSession(asset: asset,
                                                presetName: AVAssetExportPresetHighestQuality)
        else { return nil }

        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        export.outputURL = out
        export.outputFileType = .mov

        let start = CMTime(seconds: startFraction * duration, preferredTimescale: 600)
        let end = CMTime(seconds: endFraction * duration, preferredTimescale: 600)
        export.timeRange = CMTimeRange(start: start, end: end)

        await withCheckedContinuation { continuation in
            export.exportAsynchronously { continuation.resume() }
        }
        return export.status == .completed ? out : nil
    }
}
