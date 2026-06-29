//
//  NotificationFeedModels.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//
//

import Foundation

// MARK: - Feed categories
enum NotificationCategory: String {
    case all
    case followers
    case commentsLikes = "comments_likes"
    case privateMessages = "private_messages"
    case liveStreams = "live_streams"
    case newStories = "new_stories"
    case competitionsGifts = "competitions_gifts"
    case closeFriends = "close_friends"
}

// MARK: - Feed response
struct NotificationFeedResponse: Decodable {
    let items: [NotificationItem]
    let pagination: NotificationPagination?
}

struct NotificationPagination: Decodable {
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let lastPage: Int?
    let hasMore: Bool?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case perPage = "per_page"
        case total
        case lastPage = "last_page"
        case hasMore = "has_more"
    }
}

// MARK: - Feed item
struct NotificationItem: Decodable, Identifiable {
    let id: Int
    let type: Int?
    let category: String?
    let title: String?
    let actorId: Int?
    let targetId: Int?
    let timestamp: String?
    let timeAgo: String?
    let isFollowing: Bool?
    let readStatus: Bool?
    let unread: Bool?
    let actor: NotificationActor?
    let action: NotificationAction?

    enum CodingKeys: String, CodingKey {
        case id, type, category, title, timestamp, actor, action, unread
        case actorId = "actor_id"
        case targetId = "target_id"
        case timeAgo = "time_ago"
        case isFollowing = "is_following"
        case readStatus = "read_status"
    }

    /// Full URL for the actor's avatar (backend returns a relative path).
    var avatarURL: String? {
        guard let path = actor?.profilePhoto, !path.isEmpty else { return nil }
        if path.hasPrefix("http") { return path }
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return API.baseUrl + trimmed
    }

    /// The id to follow back (from the action payload, falling back to the actor).
    var followUserId: Int? { action?.payload?.userId ?? actorId }

    /// Display name for the actor (used by avatars and initials).
    var actorName: String { actor?.fullname ?? actor?.username ?? "" }

    /// Whether the notification has not been read yet. Prefers the explicit
    /// `unread` flag, then `read_status`, defaulting to unread.
    var isUnread: Bool {
        if let unread { return unread }
        if let readStatus { return !readStatus }
        return true
    }


    var isLikeAction: Bool {
        (action?.type ?? "").localizedCaseInsensitiveContains("like")
    }

    var isWinAction: Bool {
        let haystack = (action?.type ?? "") + " " + (title ?? "") + " " + (category ?? "")
        return haystack.localizedCaseInsensitiveContains("win")
            || haystack.localizedCaseInsensitiveContains("competition")
    }
}

struct NotificationActor: Decodable {
    let id: Int?
    let username: String?
    let fullname: String?
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id, username, fullname
        case profilePhoto = "profile_photo"
    }
}

struct NotificationAction: Decodable {
    let type: String?
    let method: String?
    let endpoint: String?
    let payload: Payload?

    struct Payload: Decodable {
        let userId: Int?
        enum CodingKeys: String, CodingKey { case userId = "user_id" }
    }
}

// MARK: - Time grouping (client-side, from `timestamp`)
extension NotificationItem: NotifGroupable {
    var group: NotifGroup {
        guard let date = NotificationDateParser.date(from: timestamp) else { return .previously }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return .today }
        if calendar.isDateInYesterday(date) { return .yesterday }
        if let days = calendar.dateComponents([.day], from: date, to: Date()).day, days <= 7 {
            return .last7Days
        }
        return .previously
    }
}

enum NotificationDateParser {
    private static let isoFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private static let isoPlain = ISO8601DateFormatter()
    private static let microseconds: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        return f
    }()

    static func date(from string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        return isoFractional.date(from: string)
            ?? microseconds.date(from: string)
            ?? isoPlain.date(from: string)
    }
}
