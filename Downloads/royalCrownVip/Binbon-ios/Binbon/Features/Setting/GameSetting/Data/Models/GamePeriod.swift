//
//  GamePeriod.swift
//  Binbon
//
//  Time window used to filter the game achievements & points feed.
//

import Foundation

enum GamePeriod: String, CaseIterable, Identifiable {
    case lastWeek
    case lastMonth
    case lastYear
    case allTime

    var id: String { rawValue }

    /// Localized label shown in the period dropdown.
    var title: String {
        switch self {
        case .lastWeek:  "period_last_week".localized
        case .lastMonth: "period_last_month".localized
        case .lastYear:  "period_last_year".localized
        case .allTime:   "period_all_time".localized
        }
    }

    /// Earliest date included by this period, or `nil` for "all time".
    var cutoffDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .lastWeek:  return calendar.date(byAdding: .day,   value: -7, to: now)
        case .lastMonth: return calendar.date(byAdding: .month, value: -1, to: now)
        case .lastYear:  return calendar.date(byAdding: .year,  value: -1, to: now)
        case .allTime:   return nil
        }
    }
}
