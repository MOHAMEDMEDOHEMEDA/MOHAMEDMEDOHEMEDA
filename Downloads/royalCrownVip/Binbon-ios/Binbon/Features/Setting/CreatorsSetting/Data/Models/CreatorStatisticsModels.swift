//
//  CreatorStatisticsModels.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import Foundation

// MARK: - Top tabs
enum StatisticsTab: CaseIterable, Identifiable {
    case overview, content, followers

    var id: Self { self }

    var localizedTitle: String {
        switch self {
        case .overview:  return "tab_overview".localized
        case .content:   return "tab_content".localized
        case .followers: return "followers".localized
        }
    }
}

// MARK: - Metric
enum StatisticsMetric: CaseIterable, Identifiable {
    case views, followers, likes, comments, shares, earnings

    var id: Self { self }

    var localizedTitle: String {
        switch self {
        case .views:     return "views".localized
        case .followers: return "followers".localized
        case .likes:     return "likes".localized
        case .comments:  return "comments".localized
        case .shares:    return "shares".localized
        case .earnings:  return "earnings".localized
        }
    }
}

// MARK: - Stat
struct StatisticsStat: Identifiable {
    let metric: StatisticsMetric
    let value: Int
    let deltaValue: Int
    let changePercent: Int

    var id: StatisticsMetric { metric }
}

// MARK: - Content video
struct ContentVideo: Identifiable {
    let id = UUID()
    let thumbnailName: String?
    let title: String
    let viewsCount: Int
    let date: Date
}
