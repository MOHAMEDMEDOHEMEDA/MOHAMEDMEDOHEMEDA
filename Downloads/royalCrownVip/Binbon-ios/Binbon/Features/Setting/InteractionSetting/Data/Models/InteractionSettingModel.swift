//
//  InteractionSettingModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 03/06/2026.
//

import Foundation

struct InteractionSettingResponse: Codable {
    let status: Bool
    let message: String
    let data: InteractionSettings
}

struct InteractionSettings: Codable {
    let allowComments: Bool
    let commentsPermission: InteractionPermission
    let allowMediaMessages: Bool
    let mediaMessagesPermission: InteractionPermission
    let mentionsPermission: InteractionPermission
    
    enum CodingKeys: String, CodingKey {
        case allowComments           = "allow_comments"
        case commentsPermission      = "comments_permission"
        case allowMediaMessages      = "allow_media_messages"
        case mediaMessagesPermission = "media_messages_permission"
        case mentionsPermission      = "mentions_permission"
    }
}

struct UpdateInteractionSettings: Codable {
    let allowComments: Bool
    let allowMediaMessages: Bool
    let mediaMessagesPermission: String
    let mentionsPermission: String
    
    enum CodingKeys: String, CodingKey {
        case allowComments = "allow_comments"
        case allowMediaMessages = "allow_media_messages"
        case mediaMessagesPermission = "media_messages_permission"
        case mentionsPermission = "mentions_permission"
    }
}

enum InteractionPermission: Int, Codable, CaseIterable, DynamicOptionProtocol {
    case everyone = 0
    case friends = 1
    case friendsOfFriends = 2
    case noOne            = 3
    
    var title: String {
        switch self {
        case .everyone: "audience_all".localized
        case .friends: "audience_friends".localized
        case .friendsOfFriends: "audience_friends_of_friends".localized
        case .noOne: "audience_no_one".localized
        }
    }
    
    var apiValue: String {
        switch self {
        case .everyone: "everyone"
        case .friends: "friends"
        case .friendsOfFriends: "friends_of_friends"
        case .noOne: "no_one"
        }
    }
    
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = InteractionPermission.allCases.first { $0.apiValue == raw } ?? .everyone
    }
}

struct DuetStitchResponse: Codable {
    let status: Bool
    let message: String
    let data: DuetStitchSettings
}

struct DuetStitchSettings: Codable {
    let duetEnabled: Bool
    let duetPermission: DuetStitchPermission
    let stitchEnabled: Bool
    let stitchPermission: DuetStitchPermission
    let allowedUsers: [AllowedUser]
    let meta: CursorMeta
    
    enum CodingKeys: String, CodingKey {
        case duetEnabled      = "duet_enabled"
        case duetPermission   = "duet_permission"
        case stitchEnabled    = "stitch_enabled"
        case stitchPermission = "stitch_permission"
        case allowedUsers     = "allowed_users"
        case meta
    }
}

struct AllowedUser: Codable {
    let id: Int
    let username: String
}

struct CursorMeta: Codable {
    let type: String
    let perPage: Int?
    let nextCursor: String?
    let prevCursor: String?
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case type
        case perPage    = "per_page"
        case nextCursor = "next_cursor"
        case prevCursor = "prev_cursor"
        case hasMore    = "has_more"
    }
}

enum DuetStitchPermission: String, Codable {
    case everyone
    case friends
    case friendsOfFriends = "friends_of_friends"
    case noOne            = "no_one"
    case selectedUsers    = "selected_users"
    
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = DuetStitchPermission(rawValue: raw) ?? .everyone
    }
}

struct DuetStitchUpdate: Codable {
    let enabled: Bool
    let permission: DuetStitchPermission
}

struct DuetStitchUpdateResponse: Codable {
    let status: Bool
    let message: String
    let data: DuetStitchUpdateResult
}

struct DuetStitchUpdateResult: Codable {
    let duetEnabled: Bool
    let duetPermission: DuetStitchPermission
    
    enum CodingKeys: String, CodingKey {
        case duetEnabled    = "duet_enabled"
        case duetPermission = "duet_permission"
    }
}

struct BlockedUsersResponse: Codable {
    let status: Bool
    let message: String
    let data: [BlockedUser]
    let meta: CursorMeta
}

struct BlockedUser: Codable, Identifiable {
    let id: Int
    let username: String
    let fullname: String
    let profilePhoto: String?
    let blockedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullname
        case profilePhoto = "profile_photo"
        case blockedAt    = "blocked_at"
    }
}

struct BlockUserRequest: Codable {
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case username = "user_id"
    }
}

struct BlockedUsersRequest {
    var cursor: String? = nil
    var perPage: Int? = nil
}

struct DuetUsersRequest: Codable {
    let users: [Int]
}

struct DuetUsersSearchResponse: Codable {
    let status: Bool
    let message: String
    let data: DuetUsersSearchData
}

struct DuetUsersSearchData: Codable {
    let scope: DuetSearchScope
    let query: String
    let items: [DuetSearchUser]
    let pagination: PagePagination
}

struct DuetSearchUser: Codable {
    let id: Int
    let name: String
    let username: String
    let profilePic: String?
    let isAllowed: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case username
        case profilePic = "profile_pic"
        case isAllowed  = "is_allowed"
    }
}

struct PagePagination: Codable {
    let page: Int
    let perPage: Int
    let total: Int
    let lastPage: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage  = "per_page"
        case total
        case lastPage = "last_page"
    }
}

enum DuetSearchScope: String, Codable {
    case friends
    case all
    
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = DuetSearchScope(rawValue: raw) ?? .all
    }
}
