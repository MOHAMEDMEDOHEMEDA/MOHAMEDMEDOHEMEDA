//
//  MediaCategory.swift
//  Binbon
//
//  Created by Salah Khaled on 28/04/2026.
//

import Foundation

// MARK: - Models
struct MediaCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

/// Top-left corner badge shown on a media tile, varies per profile tab.
enum MediaCornerBadge {
    case none
    case bookmark
    case heart
}

struct MediaItem: Identifiable {
    let id = UUID()
    /// Asset-catalog image name for the thumbnail.
    let assetName: String
    let views: String
    let isVideo: Bool
    /// Shows the small lock badge at the bottom-right (private items).
    let isLocked: Bool

    init(assetName: String, views: String, isVideo: Bool = true, isLocked: Bool = false) {
        self.assetName = assetName
        self.views = views
        self.isVideo = isVideo
        self.isLocked = isLocked
    }
}

struct TabData: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let categories: [MediaCategory]
    let items: [MediaItem]
    /// Corner badge applied to every tile in this tab (e.g. bookmark on Saved).
    let cornerBadge: MediaCornerBadge

    init(title: String, icon: String, categories: [MediaCategory], items: [MediaItem], cornerBadge: MediaCornerBadge = .none) {
        self.title = title
        self.icon = icon
        self.categories = categories
        self.items = items
        self.cornerBadge = cornerBadge
    }
}

// MARK: - Sample Data

private let reelThumbnails = ["media-reel-1", "media-reel-2", "media-reel-3"]
private let photoThumbnails = ["media-photo-1", "media-photo-2", "media-photo-3"]
private let sampleViews = ["15K", "15K", "15K", "12K", "9K", "7K", "22K", "8K", "5K"]

/// Builds 9 tiles cycling through a thumbnail set, applying the per-tab badges.
private func sampleItems(_ thumbnails: [String], isVideo: Bool = true, locked: Bool = false) -> [MediaItem] {
    (0..<9).map { index in
        MediaItem(
            assetName: thumbnails[index % thumbnails.count],
            views: sampleViews[index % sampleViews.count],
            isVideo: isVideo,
            isLocked: locked
        )
    }
}

let allTabs: [TabData] = [
    TabData(
        title: "Media",
        icon: "square.grid.2x2",
        categories: [
            .init(name: "cat_reels"),
            .init(name: "cat_video"),
            .init(name: "cat_photo"),
            .init(name: "cat_story"),
            .init(name: "cat_save_my_story"),
            .init(name: "cat_live"),
        ],
        items: sampleItems(reelThumbnails)
    ),
    TabData(
        title: "Private",
        icon: "lock",
        categories: [
            .init(name: "cat_all"),
            .init(name: "cat_friends"),
            .init(name: "cat_close"),
            .init(name: "cat_hidden"),
        ],
        items: sampleItems(photoThumbnails, locked: true)
    ),
    TabData(
        title: "Saved",
        icon: "bookmark",
        categories: [
            .init(name: "cat_all_saved"),
            .init(name: "cat_collections"),
            .init(name: "cat_reels"),
            .init(name: "cat_articles"),
        ],
        items: sampleItems(photoThumbnails),
        cornerBadge: .bookmark
    ),
    TabData(
        title: "Liked",
        icon: "heart",
        categories: [
            .init(name: "cat_all"),
            .init(name: "cat_videos"),
            .init(name: "cat_photos"),
            .init(name: "cat_reels"),
            .init(name: "cat_stories"),
        ],
        items: sampleItems(photoThumbnails),
        cornerBadge: .heart
    ),
]
