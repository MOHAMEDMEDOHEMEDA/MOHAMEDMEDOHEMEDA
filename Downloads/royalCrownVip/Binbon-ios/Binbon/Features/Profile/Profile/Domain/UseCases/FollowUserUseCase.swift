//
//  FollowUserUseCase.swift
//  Binbon
//

import Foundation

/// Follows another user.
struct FollowUserUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(userId: Int) async throws {
        try await repository.followUser(id: userId)
    }
}
