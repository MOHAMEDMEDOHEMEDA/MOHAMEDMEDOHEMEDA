//
//  PostDetailsViewMergeSection.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewMergeSection: View {

    @Binding var coverImage: UIImage?
    let videoURL: URL?
    let image: UIImage?
    var layout: VideoLayoutOption = .single
    var onPreview: () -> Void = {}
    var onEditCover: () -> Void = {}

    @Binding var caption: String
    var captionFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Text("post_merge_with".localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.appText)
                    PostDetailsViewMergeChip()
                }

                TextField("post_caption_placeholder".localized, text: $caption, axis: .vertical)
                    .focused(captionFocused)
                    .font(.system(size: 14))
                    .foregroundStyle(.appText)
                    .tint(Color.appText)
                    .lineLimit(2...5)

                HStack(spacing: 28) {
                    Button { insert("#") } label: {
                        Text("post_tags".localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.appText)
                    }
                    .buttonStyle(.plain)
                    Button { insert("@") } label: {
                        Text("post_mention".localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.appText)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 8)
            PostDetailsViewCoverPreview(coverImage: $coverImage,
                                        videoURL: videoURL,
                                        image: image,
                                        layout: layout,
                                        onPreview: onPreview,
                                        onEditCover: onEditCover)
        }
    }

    private func insert(_ symbol: String) {
        caption += symbol
        captionFocused.wrappedValue = true
    }
}
