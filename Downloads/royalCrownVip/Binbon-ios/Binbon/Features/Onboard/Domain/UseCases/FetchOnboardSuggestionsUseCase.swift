//
//  FetchOnboardSuggestionsUseCase.swift
//  Binbon
//
//  Domain layer — loads the suggested accounts to follow for an onboarding step.
//

import Foundation

struct FetchOnboardSuggestionsUseCase {
    private let repository: OnboardingRepositoryProtocol

    init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(step: OnboardStepEnum) async throws -> [OnboardSuggestionResponse] {
        try await repository.fetchSuggestions(step: step)
    }
}
