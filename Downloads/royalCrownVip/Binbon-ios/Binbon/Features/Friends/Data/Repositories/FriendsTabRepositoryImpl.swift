//
//  FriendsTabRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `FriendsTabRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class FriendsTabRepositoryImpl: FriendsTabRepositoryProtocol {

    private let remote: FriendsTabRemoteDataSource

    init(remote: FriendsTabRemoteDataSource) {
        self.remote = remote
    }

    func loadFriends() async throws -> [FriendItem] {
        try await remote.loadFriends()
    }
}
