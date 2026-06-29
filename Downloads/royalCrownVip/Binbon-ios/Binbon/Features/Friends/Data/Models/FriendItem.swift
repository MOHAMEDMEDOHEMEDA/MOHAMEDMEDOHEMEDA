//
//  FriendItem.swift
//  Binbon
//
//  A person shown in the Friends tab list: username, display name and the
//  current follow state. Placeholder sample data until a real friends API ships.
//

import Foundation

struct FriendItem: Identifiable, Equatable, Hashable {
    let id: UUID
    /// Handle shown in bold, e.g. "binbon".
    let username: String
    /// Full display name shown as the subtitle, e.g. "Bin Bon".
    let displayName: String
    /// Remote avatar URL when available; nil falls back to an initial badge.
    let avatarURL: String?
    var isFollowing: Bool

    init(username: String, displayName: String, avatarURL: String? = nil, isFollowing: Bool = true, id: UUID = UUID()) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.isFollowing = isFollowing
    }

    static let samples: [FriendItem] = [
        FriendItem(username: "binbon", displayName: "Bin Bon"),
        FriendItem(username: "hi", displayName: "Danny"),
        FriendItem(username: "bilalmuhammed", displayName: "Bilal MUhammed")
    ]
}
