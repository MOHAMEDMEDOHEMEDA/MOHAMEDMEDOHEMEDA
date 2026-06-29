//
//  ActivityItem.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import Foundation

enum ActivityKind: String, Decodable {
    case follow
    case like
    case comment
    case mention
    case live
    case system
}

enum ActivitySection: String {
    case today
    case yesterday
    case thisWeek
    case previously

    var localized: String {
        switch self {
        case .today: "group_today".localized
        case .yesterday: "group_yesterday".localized
        case .thisWeek: "group_last_7_days".localized   // or add "this_week" key later
        case .previously: "group_previously".localized
        }
    }
}

struct ActivityItem: Identifiable, Decodable {
    let id: Int
    let kind: ActivityKind
    let actorName: String
    let actorUsername: String?
    let actorImageURL: String?
    let message: String
    let timeAgo: String
    let timestamp: String?
    let isFollowing: Bool
    let thumbnailURL: String?
    let userId: Int?

    var displayLine: String {
        if let username = actorUsername, !username.isEmpty {
            return "\(username) \(message)"
        }
        return "\(actorName) \(message)"
    }

    var section: ActivitySection {
        guard let timestamp,
              let date = ActivityDateParser.date(from: timestamp) else {
            return .previously
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return .today }
        if calendar.isDateInYesterday(date) { return .yesterday }
        if let days = calendar.dateComponents([.day], from: date, to: Date()).day, days <= 7 {
            return .thisWeek
        }
        return .previously
    }
}

enum ActivityDateParser {
    private static let iso = ISO8601DateFormatter()

    static func date(from string: String) -> Date? {
        iso.date(from: string)
    }
}
