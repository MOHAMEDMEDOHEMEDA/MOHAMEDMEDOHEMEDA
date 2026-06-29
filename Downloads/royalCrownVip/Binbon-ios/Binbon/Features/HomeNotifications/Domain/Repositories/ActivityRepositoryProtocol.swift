//
//  ActivityRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — activity-feed boundary the use cases depend on. Returns entities
//  and throws `APIError`.
//

import Foundation

protocol ActivityRepositoryProtocol {
    func fetchActivity(page: Int, perPage: Int) async throws -> ActivityFeedResponse
    func followUser(userId: Int) async throws
    func unFollowUser(userId: Int) async throws
    func markRead(id: Int) async throws
}

extension ActivityRepositoryProtocol {
    func fetchActivity() async throws -> ActivityFeedResponse {
        try await fetchActivity(page: 1, perPage: 20)
    }
}
