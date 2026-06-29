//
//  PromoteModels.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import Foundation

// MARK: - Promote Goal
enum PromoteGoal: Int, CaseIterable, Identifiable, Codable {
    case moreVideoViews
    case moreFollowers
    case moreProfileViews

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .moreVideoViews:   return "more_video_views".localized
        case .moreFollowers:    return "more_followers".localized
        case .moreProfileViews: return "more_profile_views".localized
        }
    }

    var icon: String {
        switch self {
        case .moreVideoViews:
            return "promotion_video_views_icon"
        case .moreFollowers:
            return "promotion_followers_icon"
        case .moreProfileViews:
            return "promotion_profile_views_icon"
        }
    }
}

// MARK: - Promote Objective
enum PromoteObjective: Int, CaseIterable, Identifiable, Codable {
    case boostAccount
    case sales
    case liveBoost
    case getSubscribers

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .boostAccount:   return "boost_account".localized
        case .sales:          return "objective_sales".localized
        case .liveBoost:      return "objective_live_boost".localized
        case .getSubscribers: return "objective_get_subscribers".localized
        }
    }
}

// MARK: - Post being promoted
struct PromotePost: Codable, Identifiable {
    let id: Int
    let imageURL: String?
    let caption: String
    let postedDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
        case caption
        case postedDate = "posted_date"
    }
}

// MARK: - Pack appearance mode
enum PromotionAppearance: Int, CaseIterable, Identifiable, Codable {
    case automatic
    case custom

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .automatic: return "appearance_default".localized
        case .custom:    return "appearance_custom".localized
        }
    }
}

// MARK: - Promotion Pack
struct PromotionPack: Codable, Identifiable {
    let id: Int
    let imageURL: String?
    let reachRange: String
    let durationText: String
    let price: Double
    let isRecommended: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
        case reachRange = "reach_range"
        case durationText = "duration_text"
        case price
        case isRecommended = "is_recommended"
    }
}
