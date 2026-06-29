//
//  StoryGifOverlayView.swift
//  Binbon
//

import SwiftUI
import UIKit

struct StoryGifOverlayView: View {

    let reference: String
    let fallbackAsset: String?

    @State private var frames: [UIImage] = []
    @State private var duration: TimeInterval = 0
    @State private var didFail = false

    var body: some View {
        Group {
            if let first = frames.first {
                if frames.count > 1 {
                    TimelineView(.animation) { timeline in
                        Image(uiImage: frames[frameIndex(at: timeline.date)])
                            .resizable()
                            .scaledToFit()
                    }
                } else {
                    Image(uiImage: first)
                        .resizable()
                        .scaledToFit()
                }
            } else if didFail, let fallbackAsset {
                Image(fallbackAsset)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .frame(width: 140, height: 140)
        .task(id: reference) { await loadGIF() }
    }

    private func frameIndex(at date: Date) -> Int {
        guard !frames.isEmpty, duration > 0 else { return 0 }
        let elapsed = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration)
        let progress = elapsed / duration
        return min(Int(progress * Double(frames.count)), frames.count - 1)
    }

    private func loadGIF() async {
        frames = []
        didFail = false

        let decoded = await Task.detached(priority: .userInitiated) {
            StoryGifDecoder.decode(reference: reference)
        }.value

        if let decoded {
            frames = decoded.images
            duration = decoded.duration
        } else {
            didFail = true
        }
    }
}
