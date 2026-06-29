//
//  LoadFriendsUseCase.swift
//  Binbon
//
//  Domain layer — loads the Friends tab list.
//

import Foundation

struct LoadFriendsUseCase {
    private let repository: FriendsTabRepositoryProtocol

    init(repository: FriendsTabRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [FriendItem] {
        try await repository.loadFriends()
    }
}
