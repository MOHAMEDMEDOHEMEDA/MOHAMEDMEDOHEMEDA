//
//  RecommendedUsersUseCase.swift
//  Binbon
//

import Foundation

/// Fetches suggested users to follow.
struct RecommendedUsersUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(limit: Int) async throws -> [RecommendUserResponse] {
        try await repository.recommendedUsers(limit: limit)
    }
}
