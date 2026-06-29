//
//  PostDetailsViewCoverPreview.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewCoverPreview: View {

    @Binding var coverImage: UIImage?
    let videoURL: URL?
    let image: UIImage?
    var layout: VideoLayoutOption = .single
    var onPreview: () -> Void = {}
    var onEditCover: () -> Void = {}

    var body: some View {
        ZStack {
            Group {
                if let coverImage {
                    Image(uiImage: coverImage).resizable().scaledToFill()
                } else if videoURL != nil {
                    CapturedVideoLayoutView(videoURL: videoURL, image: image, layout: layout,
                                            videoVolume: 0)
                } else if let image {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    AppColor.cardBackground
                }
            }
            .frame(width: 112, height: 146)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack {
                Button(action: onPreview) { PostDetailsViewCoverBadge(text: "post_preview".localized) }
                    .buttonStyle(.plain)
                Spacer()
                Button(action: onEditCover) { PostDetailsViewCoverBadge(text: "post_edit_cover".localized) }
                    .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
        }
        .frame(width: 112, height: 146)
    }
}
