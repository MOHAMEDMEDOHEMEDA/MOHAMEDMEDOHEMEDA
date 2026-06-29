//
//  LiveStreamModels.swift
//  Binbon
//
//  Created by Ramez Hamdy on 07/06/2026.
//

import Foundation

enum LiveAudience: Int, CaseIterable, Identifiable {
    case everyone = 0        // عام (Public)
    case friends             // الأصدقاء
    case followers           // المتابعين
    case subscribers         // المشتركين
    case passwordProtected   // بث خاص بكلمة سر

    var id: Int { rawValue }

    var titleKey: String {
        switch self {
        case .everyone:          "audience_public"
        case .friends:           "audience_friends"
        case .followers:         "audience_followers"
        case .subscribers:       "audience_subscribers"
        case .passwordProtected: "audience_password"
        }
    }

    var title: String { titleKey.localized }

    /// `live_visibility` (PrivacyP4: 0 everyone, 1 friends, 2 friends_of_friends, 3 nobody).
    var liveVisibility: Int {
        switch self {
        case .everyone:          0
        case .friends:           1
        case .followers:         2
        case .subscribers:       3
        case .passwordProtected: 0
        }
    }

    /// `live_type` (SettingPrivacy: 0 public, 1 private, 2 password_protected).
    var liveType: Int {
        switch self {
        case .everyone, .friends, .followers: 0
        case .subscribers:                    1
        case .passwordProtected:              2
        }
    }

    /// Reverse map from the API's two fields back to a single radio.
    init(visibility: Int?, type: Int?) {
        if type == 2 {
            self = .passwordProtected
            return
        }
        switch visibility {
        case 1:  self = .friends
        case 2:  self = .followers
        case 3:  self = .subscribers
        default: self = .everyone
        }
    }
}

// MARK: - Settings (GET /api/user/settings/live-stream)
struct LiveStreamSettings: Decodable {
    let commentsEnabled: Bool?
    let giftsEnabled: Bool?
    let liveVisibility: Int?
    let liveType: Int?
    let livePasswordEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case commentsEnabled = "comments_enabled"
        case giftsEnabled = "gifts_enabled"
        case liveVisibility = "live_visibility"
        case liveType = "live_type"
        case livePasswordEnabled = "live_password_enabled"
    }
}

// MARK: - Settings update (PATCH, partial)
struct LiveStreamUpdateRequest: Encodable {
    let commentsEnabled: Bool
    let giftsEnabled: Bool
    let liveVisibility: Int
    let liveType: Int
    let livePassword: String?
    let clearLivePassword: Bool?

    enum CodingKeys: String, CodingKey {
        case commentsEnabled = "comments_enabled"
        case giftsEnabled = "gifts_enabled"
        case liveVisibility = "live_visibility"
        case liveType = "live_type"
        case livePassword = "live_password"
        case clearLivePassword = "clear_live_password"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(commentsEnabled, forKey: .commentsEnabled)
        try container.encode(giftsEnabled, forKey: .giftsEnabled)
        try container.encode(liveVisibility, forKey: .liveVisibility)
        try container.encode(liveType, forKey: .liveType)
        try container.encodeIfPresent(livePassword, forKey: .livePassword)
        try container.encodeIfPresent(clearLivePassword, forKey: .clearLivePassword)
    }
}

// MARK: - Schedules (GET/POST/DELETE …/live-stream/schedules)
struct LiveSchedule: Decodable, Identifiable {
    let id: Int
    let title: String?
    let scheduledFor: String?
    let timezone: String?
    let liveVisibility: Int?
    let liveType: Int?
    let commentsEnabled: Bool?
    let giftsEnabled: Bool?
    let invitedUserIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case id, title, timezone
        case scheduledFor = "scheduled_for"
        case liveVisibility = "live_visibility"
        case liveType = "live_type"
        case commentsEnabled = "comments_enabled"
        case giftsEnabled = "gifts_enabled"
        case invitedUserIds = "invited_user_ids"
    }

    /// Parsed `scheduled_for` (ISO-8601, the absolute UTC instant).
    private var date: Date? {
        guard let scheduledFor else { return nil }
        return Date.from(iso: scheduledFor)
    }

    /// e.g. "الأحد 07/06/2026" — the instant in the viewer's local zone.
    var dateDisplay: String {
        guard let date else { return scheduledFor ?? "" }
        return date.display("EEEE dd/MM/yyyy")
    }

    /// e.g. "04:00 PM" — the instant in the viewer's local zone (Egypt +3, etc.).
    var timeDisplay: String {
        guard let date else { return "" }
        return date.display("hh:mm a")
    }
}

struct LiveScheduleListResponse: Decodable {
    let items: [LiveSchedule]?
}

// MARK: - Schedule create (POST)
struct LiveScheduleRequest: Encodable {
    let title: String
    /// ISO-8601 with the device's local offset, e.g. "2026-12-22T20:30:00+02:00".
    let scheduledFor: String
    let liveVisibility: Int
    let liveType: Int
    let commentsEnabled: Bool
    let giftsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case title
        case scheduledFor = "scheduled_for"
        case liveVisibility = "live_visibility"
        case liveType = "live_type"
        case commentsEnabled = "comments_enabled"
        case giftsEnabled = "gifts_enabled"
    }
}
