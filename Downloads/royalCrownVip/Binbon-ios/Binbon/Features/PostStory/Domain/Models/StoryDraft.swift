//
//  StoryDraft.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import SwiftUI

struct StoryDraft: Equatable {
    var mediaImage: UIImage?
    var mediaVideoURL: URL?
    var overlays: [StoryOverlay]
    var soundFileName: String?
    var filter: VideoFilter
    var photoScale: CGFloat
    var photoRotation: Angle

    init(
        mediaImage: UIImage? = nil,
        mediaVideoURL: URL? = nil,
        overlays: [StoryOverlay] = [],
        soundFileName: String? = nil,
        filter: VideoFilter = .none,
        photoScale: CGFloat = 1,
        photoRotation: Angle = .zero
    ) {
        self.mediaImage = mediaImage
        self.mediaVideoURL = mediaVideoURL
        self.overlays = overlays
        self.soundFileName = soundFileName
        self.filter = filter
        self.photoScale = photoScale
        self.photoRotation = photoRotation
    }
}
