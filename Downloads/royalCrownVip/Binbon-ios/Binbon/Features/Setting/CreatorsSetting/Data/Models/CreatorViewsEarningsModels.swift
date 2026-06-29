//
//  CreatorViewsEarningsModels.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import Foundation

// MARK: - Period filter
enum CreatorViewsPeriod: CaseIterable, Identifiable {
    case weekly, monthly, yearly, custom

    var id: Self { self }

    var localizedTitle: String {
        switch self {
        case .weekly:  return "filter_weekly".localized
        case .monthly: return "filter_monthly".localized
        case .yearly:  return "filter_yearly".localized
        case .custom:  return "filter_custom".localized
        }
    }
}

// MARK: - Metric
enum CreatorViewsMetric: CaseIterable, Identifiable {
    case views, adCount, earnings

    var id: Self { self }

    var localizedTitle: String {
        switch self {
        case .views:    return "views".localized
        case .adCount:  return "ad_count".localized
        case .earnings: return "earnings".localized
        }
    }
}

// MARK: - Stat
struct CreatorMetricStat: Identifiable {
    let metric: CreatorViewsMetric
    let value: Int
    let deltaValue: Int
    let changePercent: Int

    var id: CreatorViewsMetric { metric }
}
