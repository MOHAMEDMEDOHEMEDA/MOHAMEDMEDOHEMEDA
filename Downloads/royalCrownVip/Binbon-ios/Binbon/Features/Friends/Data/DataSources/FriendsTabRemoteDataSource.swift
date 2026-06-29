//
//  FriendsTabRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the Friends tab. Mock-backed for now.
//

import Foundation

protocol FriendsTabRemoteDataSource {
    func loadFriends() async throws -> [FriendItem]
}

// MARK: - Mock

struct MockFriendsTabRemoteDataSource: FriendsTabRemoteDataSource {
    func loadFriends() async throws -> [FriendItem] {
        FriendItem.samples
    }
}
