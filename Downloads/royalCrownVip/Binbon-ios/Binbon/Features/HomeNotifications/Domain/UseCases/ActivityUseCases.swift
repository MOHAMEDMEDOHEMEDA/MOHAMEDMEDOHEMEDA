//
//  ActivityUseCases.swift
//  Binbon
//
//  Domain layer — activity-feed use cases.
//

import Foundation

struct FetchActivityUseCase {
    private let repository: ActivityRepositoryProtocol
    init(repository: ActivityRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> ActivityFeedResponse {
        try await repository.fetchActivity()
    }
}

struct FollowFromActivityUseCase {
    private let repository: ActivityRepositoryProtocol
    init(repository: ActivityRepositoryProtocol) { self.repository = repository }
    func execute(userId: Int) async throws {
        try await repository.followUser(userId: userId)
    }
}
