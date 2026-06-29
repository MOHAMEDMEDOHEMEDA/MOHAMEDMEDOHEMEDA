//
//  LiveStreamSettingModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 06/06/2026.
//

import Foundation

// MARK: - Query Request

struct LiveStreamFilterRequest {
    let filter: String?
    let query: String?
    let perPage: Int?

    init(filter: String? = nil, query: String? = nil, perPage: Int? = 20) {
        self.filter = filter
        self.query = query
        self.perPage = perPage
    }
}

// MARK: - GET Response

struct LiveStreamSettingResponse: Codable {
    let commentsEnabled: Bool?
    let giftsEnabled: Bool?
    let liveVisibility: Int?
    let liveType: Int?
    let livePasswordEnabled: Bool?

    let audienceFilter: String?
    let items: [LiveAudienceUser]?
    let pagination: LivePagination?

    let visibilityOptions: [LiveOption]?
    let typeOptions: [LiveOption]?

    enum CodingKeys: String, CodingKey {
        case commentsEnabled = "comments_enabled"
        case giftsEnabled = "gifts_enabled"
        case liveVisibility = "live_visibility"
        case liveType = "live_type"
        case livePasswordEnabled = "live_password_enabled"
        case audienceFilter = "audience_filter"
        case items
        case pagination
        case visibilityOptions = "visibility_options"
        case typeOptions = "type_options"
    }
}

// MARK: - Audience User

struct LiveAudienceUser: Codable, Identifiable {
    let id: Int
    let username: String
    let fullname: String
    let profilePhoto: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullname
        case profilePhoto = "profile_photo"
    }
}

// MARK: - Pagination

struct LivePagination: Codable {
    let currentPage: Int
    let perPage: Int
    let total: Int
    let lastPage: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case perPage = "per_page"
        case total
        case lastPage = "last_page"
    }
}

// MARK: - Options

struct LiveOption: Codable, Identifiable {
    let key: Int
    let label: String

    var id: Int { key }
}

enum LiveVisibility: Int, CaseIterable, Identifiable, DynamicOptionProtocol{
    case everyone = 0
    case friends = 1
    case friendsOfFriends = 2
    case nobody = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .everyone:
            return "audience_all".localized

        case .friends:
            return "audience_friends".localized

        case .friendsOfFriends:
            return "audience_friends_of_friends".localized

        case .nobody:
            return "audience_no_one".localized
        }
    }
}

enum LiveStreamType: Int, CaseIterable, Identifiable, DynamicOptionProtocol {
    case `public` = 0
    case `private` = 1

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .public:
            return "live_public".localized

        case .private:
            return "live_private".localized
        }
    }
}

enum CommentsAllowance: Int, DynamicOptionProtocol {
    case allow = 0
    case disable = 1

    var title: String {
        switch self {
        case .allow: "allow".localized
        case .disable: "disable".localized
        }
    }

    var isEnabled: Bool { self == .allow }

    init(enabled: Bool) {
        self = enabled ? .allow : .disable
    }
}
