//
//  BroadcastsListModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 14/06/2026.
//

import Foundation

// MARK: - Live Broadcast
struct LiveBroadcast: Identifiable, Hashable {
    let id: String
    let previewImageName: String
    let isHot: Bool
}

// MARK: - Celebrity News banner
struct LiveNewsBanner: Hashable {
    var titleKey: String = "live_news_title"
    var badgeKey: String = "live_news_badge_breaking"
    var headlines: [String] = []
    var backgroundImageName: String? = nil
}
