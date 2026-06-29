//
//  OnboardingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — onboarding boundary the use cases depend on. Returns entities
//  and throws `APIError`; action endpoints complete with no value on success.
//

import Foundation

protocol OnboardingRepositoryProtocol {
    func fetchSuggestions(step: OnboardStepEnum) async throws -> [OnboardSuggestionResponse]
    func followSelected(userIds: [Int]) async throws
    func followAll() async throws
    func complete(action: String) async throws
}
