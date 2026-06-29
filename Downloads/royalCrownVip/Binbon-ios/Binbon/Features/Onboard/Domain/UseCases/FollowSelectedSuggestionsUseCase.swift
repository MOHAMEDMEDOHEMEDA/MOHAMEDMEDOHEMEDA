//
//  FollowSelectedSuggestionsUseCase.swift
//  Binbon
//
//  Domain layer — follows the subset of suggested accounts the user picked.
//

import Foundation

struct FollowSelectedSuggestionsUseCase {
    private let repository: OnboardingRepositoryProtocol

    init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userIds: [Int]) async throws {
        try await repository.followSelected(userIds: userIds)
    }
}
