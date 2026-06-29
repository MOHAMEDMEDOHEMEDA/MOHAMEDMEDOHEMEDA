//
//  FollowAllSuggestionsUseCase.swift
//  Binbon
//
//  Domain layer — follows every suggested account for the current step.
//

import Foundation

struct FollowAllSuggestionsUseCase {
    private let repository: OnboardingRepositoryProtocol

    init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.followAll()
    }
}
