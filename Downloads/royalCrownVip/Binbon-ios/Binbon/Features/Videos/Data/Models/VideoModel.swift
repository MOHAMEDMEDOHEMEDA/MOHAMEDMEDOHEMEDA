//
//  ReelsViewModel.swift
//  Binbon
//
//  Created by Mostafa Sobaih on 04/06/2026.
//

import Foundation

struct VideoModel: Identifiable, Hashable {
    let id: String
    let thumbnailURL: String?
    let videoURL: URL?
    let duration: String
    let title: String
    let hashtags: String
    let views: String
    let age: String
    let authorName: String
    let authorAvatarURL: String?
}

/// Selectable streaming quality for the player (mock until real renditions exist).
/// Shared by the videos feed and the video details player.
enum VideoQuality: String, CaseIterable, Identifiable {
    case auto, p1080 = "1080p", p720 = "720p", p480 = "480p"

    var id: String { rawValue }
    var label: String { self == .auto ? "quality_auto".localized : rawValue }
    /// Short label shown in the on-player badge.
    var badge: String { self == .auto ? "HD" : rawValue }
}
