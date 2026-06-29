//
//  SecurityActivityModel.swift
//  Binbon
//
//  Created by Claude on 05/06/2026.
//

import Foundation

// MARK: - Network Response
struct SecurityActivityResponse: Decodable {

    let groups: [String: [SecurityActivity]]?
    let pagination: SecurityActivityPagination?
}

struct SecurityActivity: Decodable {

    let activityType: String?
    let detail: String?
    let timestamp: String?

    enum CodingKeys: String, CodingKey {
        case activityType = "activity_type"
        case detail = "description"
        case timestamp
    }
}

struct SecurityActivityPagination: Decodable {

    let currentPage: Int?
    let lastPage: Int?
    let perPage: Int?
    let total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }

    var hasMore: Bool {
        guard let currentPage, let lastPage else { return false }
        return currentPage < lastPage
    }
}

// MARK: - Display Models
struct SecurityActivitySection: Identifiable {

    let id: String
    let title: String
    let rows: [SecurityActivityRow]
}

struct SecurityActivityRow: Identifiable {

    let id: Int
    let title: String
    let relativeTime: String
    let iconName: String
}

// MARK: - Date Handling
enum SecurityActivityDate {

    private static let parser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private static let monthHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter
    }()

    static var currentLocale: Locale {
        Language(rawValue: Storage.shared.language)?.locale ?? Language.english.locale
    }

    static func date(from string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        return parser.date(from: string)
    }

    static func monthTitle(for date: Date) -> String {
        monthHeaderFormatter.locale = currentLocale
        return monthHeaderFormatter.string(from: date)
    }

    static func relativeString(from date: Date) -> String {
        relativeFormatter.locale = currentLocale
        let value = relativeFormatter.localizedString(for: date, relativeTo: Date())
        guard let first = value.first else { return value }
        return first.uppercased() + value.dropFirst()
    }
}

// MARK: - Date Filter
enum ActivityDateFilter: Int, DynamicOptionProtocol {

    case lastMonth = 0
    case lastWeek = 1
    case today = 2

    var title: String {
        switch self {
        case .lastMonth: "filter_last_month".localized
        case .lastWeek: "filter_last_week".localized
        case .today: "filter_today".localized
        }
    }

    func contains(_ date: Date, reference: Date = Date(), calendar: Calendar = .current) -> Bool {
        switch self {
        case .today:
            calendar.isDateInToday(date)
        case .lastWeek:
            date >= (calendar.date(byAdding: .day, value: -7, to: reference) ?? reference)
        case .lastMonth:
            date >= (calendar.date(byAdding: .month, value: -1, to: reference) ?? reference)
        }
    }
}

// MARK: - Icon Mapping
enum SecurityActivityIcon {

    static func name(for activityType: String?) -> String {
        switch activityType {
        case "biometric_updated", "biometric_enabled", "biometric_disabled":
            "faceid"
        case "password_changed", "password_updated", "password_reset":
            "key.fill"
        case "two_factor_enabled", "two_factor_disabled", "2fa_updated":
            "lock.shield.fill"
        case "login", "sign_in", "new_login", "new_device", "new_browser":
            "person.crop.circle.badge.checkmark"
        case "logout", "sign_out", "device_logout", "device_logout_all":
            "rectangle.portrait.and.arrow.right.fill"
        default:
            "clock.fill"
        }
    }
}
