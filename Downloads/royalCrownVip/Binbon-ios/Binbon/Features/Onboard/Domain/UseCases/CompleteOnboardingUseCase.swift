//
//  CompleteOnboardingUseCase.swift
//  Binbon
//
//  Domain layer — records that the user finished (or skipped) an onboarding step.
//

import Foundation

struct CompleteOnboardingUseCase {
    private let repository: OnboardingRepositoryProtocol

    init(repository: OnboardingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(action: String) async throws {
        try await repository.complete(action: action)
    }
}
