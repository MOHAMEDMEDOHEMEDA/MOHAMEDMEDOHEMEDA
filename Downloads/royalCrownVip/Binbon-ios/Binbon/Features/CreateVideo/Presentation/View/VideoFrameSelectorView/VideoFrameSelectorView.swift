//
//  VideoFrameSelectorView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import SwiftUI

struct VideoFrameSelectorView: View {

    let url: URL
    var onSelect: (UIImage) -> Void = { _ in }
    var onClose: () -> Void = {}

    @State private var duration: Double = 0
    @State private var fraction: Double = 0
    @State private var previewImage: UIImage?
    @State private var thumbnails: [UIImage] = []

    private let generator: AVAssetImageGenerator
    private let stripHeight: CGFloat = 56

    init(url: URL, onSelect: @escaping (UIImage) -> Void = { _ in }, onClose: @escaping () -> Void = {}) {
        self.url = url
        self.onSelect = onSelect
        self.onClose = onClose
        let gen = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        gen.appliesPreferredTrackTransform = true
        gen.requestedTimeToleranceBefore = .zero
        gen.requestedTimeToleranceAfter = .zero
        self.generator = gen
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                VideoFrameSelectorViewTopBar(
                    canSelect: previewImage != nil,
                    onClose: onClose,
                    onDone: {
                        if let previewImage { onSelect(previewImage) }
                        onClose()
                    }
                )

                Spacer()
                Group {
                    if let previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        ProgressView().tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                Spacer()

                VideoFrameSelectorViewStrip(
                    fraction: $fraction,
                    thumbnails: thumbnails,
                    stripHeight: stripHeight,
                    onScrub: { Task { await updatePreview() } }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await loadDuration()
            await loadThumbnails()
            await updatePreview()
        }
    }

    // MARK: - Loading
    private func loadDuration() async {
        if let cm = try? await AVURLAsset(url: url).load(.duration) {
            duration = CMTimeGetSeconds(cm)
        }
    }

    private func updatePreview() async {
        guard duration > 0 else { return }
        let time = CMTime(seconds: fraction * duration, preferredTimescale: 600)
        if let result = try? await generator.image(at: time) {
            previewImage = UIImage(cgImage: result.image)
        }
    }

    private func loadThumbnails() async {
        guard duration > 0 else { return }
        let thumbGen = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        thumbGen.appliesPreferredTrackTransform = true
        thumbGen.maximumSize = CGSize(width: 120, height: 160)
        thumbGen.requestedTimeToleranceBefore = .positiveInfinity
        thumbGen.requestedTimeToleranceAfter = .positiveInfinity

        let count = 10
        var images: [UIImage] = []
        for i in 0..<count {
            let time = CMTime(seconds: duration * Double(i) / Double(count), preferredTimescale: 600)
            if let result = try? await thumbGen.image(at: time) {
                images.append(UIImage(cgImage: result.image))
            }
        }
        thumbnails = images
    }
}
