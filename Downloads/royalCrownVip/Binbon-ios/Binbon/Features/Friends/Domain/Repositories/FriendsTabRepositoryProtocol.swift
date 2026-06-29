//
//  FriendsTabRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — Friends tab boundary the use cases depend on.
//

import Foundation

protocol FriendsTabRepositoryProtocol {
    func loadFriends() async throws -> [FriendItem]
}
