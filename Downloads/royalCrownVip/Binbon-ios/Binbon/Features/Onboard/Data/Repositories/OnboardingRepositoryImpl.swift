//
//  OnboardingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `OnboardingRepositoryProtocol`, driving the remote data
//  source. Errors surface as thrown `APIError`.
//

import Foundation

final class OnboardingRepositoryImpl: OnboardingRepositoryProtocol {

    private let remote: OnboardRemoteDataSource

    init(remote: OnboardRemoteDataSource) {
        self.remote = remote
    }

    func fetchSuggestions(step: OnboardStepEnum) async throws -> [OnboardSuggestionResponse] {
        try await remote.fetchSuggestions(step: step)
    }

    func followSelected(userIds: [Int]) async throws {
        try await remote.followSelected(userIds: userIds)
    }

    func followAll() async throws {
        try await remote.followAll()
    }

    func complete(action: String) async throws {
        try await remote.complete(action: action)
    }
}
