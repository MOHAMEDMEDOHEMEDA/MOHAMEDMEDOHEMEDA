//
//  RemoveFollowerUseCase.swift
//  Binbon
//

import Foundation

/// Removes a follower from the signed-in user's followers list.
struct RemoveFollowerUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(userId: Int) async throws {
        try await repository.removeFollower(id: userId)
    }
}
