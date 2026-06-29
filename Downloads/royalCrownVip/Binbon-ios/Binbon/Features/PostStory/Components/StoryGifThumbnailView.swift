//
//  StoryGifThumbnailView.swift
//  Binbon
//

import SwiftUI
import UIKit

struct StoryGifThumbnailView: View {

    let item: StoryGifItem

    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else if let asset = item.previewAsset {
                Image(asset)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.appText.opacity(0.1)
            }
        }
        .task(id: item.id) { await loadThumbnail() }
    }

    private func loadThumbnail() async {
        let image = await Task.detached(priority: .userInitiated) {
            StoryGifDecoder.firstFrame(reference: item.previewURL)
        }.value
        thumbnail = image
    }
}
