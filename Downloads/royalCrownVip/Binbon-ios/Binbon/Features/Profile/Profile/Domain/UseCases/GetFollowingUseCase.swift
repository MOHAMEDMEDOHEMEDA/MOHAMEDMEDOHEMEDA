//
//  GetFollowingUseCase.swift
//  Binbon
//

import Foundation

/// Fetches the accounts the signed-in user follows.
struct GetFollowingUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute() async throws -> [FollowUserResponse] {
        try await repository.following()
    }
}
