//
//  PostDetailsViewContent.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostDetailsViewContent: View {

    @Binding var coverImage: UIImage?
    @Binding var selectedLocation: String?
    @Binding var caption: String
    var captionFocused: FocusState<Bool>.Binding
    let videoURL: URL?
    let image: UIImage?
    var layout: VideoLayoutOption = .single
    let suggestedLocations: [String]
    var onPreview: () -> Void = {}
    var onEditCover: () -> Void = {}
    var onPickLocation: () -> Void = {}
    var onShowSettings: () -> Void = {}
    var onPrivacy: () -> Void = {}
    var onMoreOptions: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            PostDetailsViewMergeSection(coverImage: $coverImage,
                                        videoURL: videoURL,
                                        image: image,
                                        layout: layout,
                                        onPreview: onPreview,
                                        onEditCover: onEditCover,
                                        caption: $caption,
                                        captionFocused: captionFocused)
            Divider().overlay(Color.appText.opacity(0.18))
            PostDetailsViewLocationSection(selectedLocation: $selectedLocation,
                                           suggestedLocations: suggestedLocations,
                                           onPickLocation: onPickLocation)
            PostDetailsViewOptionsList(onShowSettings: onShowSettings, onPrivacy: onPrivacy,
                                       onMoreOptions: onMoreOptions)
        }
        .padding(.horizontal, 24)
        .padding(.top, 4)
        .padding(.bottom, 24)
    }
}
