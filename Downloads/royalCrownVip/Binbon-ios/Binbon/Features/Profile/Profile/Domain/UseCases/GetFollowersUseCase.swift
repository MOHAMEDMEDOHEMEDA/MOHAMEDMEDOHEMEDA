//
//  GetFollowersUseCase.swift
//  Binbon
//

import Foundation

/// Fetches the signed-in user's followers.
struct GetFollowersUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute() async throws -> [FollowUserResponse] {
        try await repository.followers()
    }
}
