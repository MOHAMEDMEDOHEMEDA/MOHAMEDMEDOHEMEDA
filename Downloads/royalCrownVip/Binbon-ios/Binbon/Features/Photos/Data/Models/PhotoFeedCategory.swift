//
//  PhotoFeedCategory.swift
//  Binbon
//

import Foundation

// MARK: - Category

enum PhotoFeedCategory: String, CaseIterable, Identifiable {
    case reels, videos, photo, story, live

    var id: String { rawValue }

    var title: String {
        switch self {
        case .reels:  "home_tab_reels".localized
        case .videos: "home_tab_videos".localized
        case .photo:  "home_tab_photos".localized
        case .story:  "home_tab_story".localized
        case .live:   "home_tab_live".localized
        }
    }
}
