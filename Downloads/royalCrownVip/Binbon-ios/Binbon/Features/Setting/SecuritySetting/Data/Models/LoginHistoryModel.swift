//
//  LoginHistoryModel.swift
//  Binbon
//
//  Created by Claude on 07/06/2026.
//

import Foundation

// MARK: - Network Response
struct LoginHistoryResponse: Decodable {

    let items: [LoginHistoryItem]?
    let pagination: SecurityActivityPagination?
}

struct LoginHistoryItem: Decodable {

    let id: Int
    let deviceName: String?
    let ip: String?
    let location: String?
    let loginTime: String?
    let isNewDevice: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case deviceName = "device_name"
        case ip
        case location
        case loginTime = "login_time"
        case isNewDevice = "is_new_device"
    }
}

// MARK: - Display Models
struct LoginHistorySection: Identifiable {

    let id: String
    let title: String
    let rows: [LoginHistoryRow]
}

struct LoginHistoryRow: Identifiable {

    let id: Int
    let title: String
    let time: String
    let iconAsset: String
    let isNewDevice: Bool
}

// MARK: - Date Handling
enum LoginHistoryDate {

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    private static let dayHeaderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    private static let dayKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func dayTitle(for date: Date) -> String {
        dayHeaderFormatter.locale = SecurityActivityDate.currentLocale
        return dayHeaderFormatter.string(from: date)
    }

    static func dayKey(for date: Date) -> String {
        dayKeyFormatter.string(from: date)
    }

    static func timeString(from date: Date) -> String {
        timeFormatter.locale = SecurityActivityDate.currentLocale
        return timeFormatter.string(from: date)
    }
}

// MARK: - Icon Mapping
enum LoginHistoryIcon {

    static func assetName(for deviceName: String?) -> String {
        let name = (deviceName ?? "").lowercased()
        if name.contains("android") {
            return "android"
        }
        if name.contains("iphone") || name.contains("ipad") ||
           name.contains("ios") || name.contains("mac") || name.contains("apple") {
            return "ios"
        }
        return "device"
    }
}
