//
//  StoryPublishRequest.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import Foundation
import SwiftUI

struct StoryPublishRequest: Encodable {
    let hasImage: Bool
    let hasVideo: Bool
    let overlayCount: Int
    let soundFileName: String?
    let filter: String?
    let photoScale: CGFloat
    let photoRotationDegrees: Double

    init(from draft: StoryDraft) {
        hasImage = draft.mediaImage != nil
        hasVideo = draft.mediaVideoURL != nil
        overlayCount = draft.overlays.count
        soundFileName = draft.soundFileName
        filter = draft.filter == .none ? nil : draft.filter.rawValue
        photoScale = draft.photoScale
        photoRotationDegrees = draft.photoRotation.degrees
    }
}
