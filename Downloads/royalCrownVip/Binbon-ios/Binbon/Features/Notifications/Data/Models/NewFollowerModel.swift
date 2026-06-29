//
//  NewFollowerModel.swift
//  Binbon
//
//  Created by Husayn on 09/06/2026.
//

import Foundation

/// A "new follower" entry shown in the notifications feed.
struct NewFollower: Identifiable, Codable {
    let id: Int
    let name: String
    let imageURL: String?
    let timeAgo: String
    var isFollowing: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "image_url"
        case timeAgo = "time_ago"
        case isFollowing = "is_following"
    }
}
