//
//  StorySettingsModel.swift
//  Binbon
//
//  Created by Husayn on 04/06/2026.
//

import Foundation

// MARK: - Response
struct StorySettingsResponse: Codable {
    let storyVisibility: String
    let storyReplyPermissions: String
    let autoSaveStories: Bool
    let shareToOtherAccounts: Bool

    enum CodingKeys: String, CodingKey {
        case storyVisibility = "story_visibility"
        case storyReplyPermissions = "story_reply_permissions"
        case autoSaveStories = "auto_save_stories"
        case shareToOtherAccounts = "share_to_other_accounts"
    }
}

// MARK: - Request
struct StorySettingsRequest: Encodable {
    let storyVisibility: String
    let storyReplyPermissions: String
    let autoSaveStories: Bool
    let shareToOtherAccounts: Bool

    enum CodingKeys: String, CodingKey {
        case storyVisibility = "story_visibility"
        case storyReplyPermissions = "story_reply_permissions"
        case autoSaveStories = "auto_save_stories"
        case shareToOtherAccounts = "share_to_other_accounts"
    }
}

// MARK: - Yes/No Enum
enum YesNoEnum: Int, DynamicOptionProtocol {
    case yes = 0
    case no = 1

    var title: String {
        switch self {
        case .yes: "yes".localized
        case .no: "no".localized
        }
    }

    var boolValue: Bool {
        self == .yes
    }

    init(from bool: Bool) {
        self = bool ? .yes : .no
    }
}

// MARK: - Privacy Enum
enum StoryPrivacyEnum: Int, DynamicOptionProtocol {
    case everyone = 0
    case friends = 1
    case friendsOfFriends = 2
    case noOne = 3

    var title: String {
        switch self {
        case .everyone: "everyone".localized
        case .friends: "friends".localized
        case .friendsOfFriends: "friends_of_friends".localized
        case .noOne: "no_one".localized
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

    init?(apiValue: String) {
        switch apiValue {
        case "everyone": self = .everyone
        case "friends": self = .friends
        case "friends_of_friends": self = .friendsOfFriends
        case "no_one": self = .noOne
        default: return nil
        }
    }
}
