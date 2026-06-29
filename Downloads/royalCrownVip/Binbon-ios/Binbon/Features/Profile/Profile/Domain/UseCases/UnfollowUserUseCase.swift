//
//  UnfollowUserUseCase.swift
//  Binbon
//

import Foundation

/// Unfollows a user the signed-in user currently follows.
struct UnfollowUserUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(userId: Int) async throws {
        try await repository.unfollowUser(id: userId)
    }
}
