//
//  PrivacySettingModel.swift
//  Binbon
//
//  Created by Salah Khaled on 24/05/2026.
//

import Foundation

struct PrivacySettingModel: Codable {
    
    let id: Int?
    let userId: Int?
    let profileVisibility: Int?
    let onlineTimeVisibility: Int?
    let friendRequestPrivacy: Int?
    let dmPrivacy: Int?
    let commentPrivacy: Int?
    let mentionPrivacy: Int?
    let storyPrivacy: Int?
    let sharePostPrivacy: Int?
    let activityStatusVisibility: Int?
    let incognitoMode: Bool?

    enum CodingKeys: String, CodingKey {
        
        case id
        case userId = "user_id"
        case profileVisibility = "profile_visibility"
        case onlineTimeVisibility = "online_time_visibility"
        case friendRequestPrivacy = "friend_request_privacy"
        case dmPrivacy = "dm_privacy"
        case commentPrivacy = "comment_privacy"
        case mentionPrivacy = "mention_privacy"
        case storyPrivacy = "story_privacy"
        case sharePostPrivacy = "share_post_privacy"
        case activityStatusVisibility = "activity_status_visibility"
        case incognitoMode = "incognito_mode"
    }
}
