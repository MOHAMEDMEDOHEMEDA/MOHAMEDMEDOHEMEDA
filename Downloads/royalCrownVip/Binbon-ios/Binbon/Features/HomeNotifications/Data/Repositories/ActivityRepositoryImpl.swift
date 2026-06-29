//
//  ActivityRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `ActivityRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class ActivityRepositoryImpl: ActivityRepositoryProtocol {

    private let remote: ActivityRemoteDataSource

    init(remote: ActivityRemoteDataSource) {
        self.remote = remote
    }

    func fetchActivity(page: Int, perPage: Int) async throws -> ActivityFeedResponse {
        try await remote.fetchActivity(page: page, perPage: perPage)
    }

    func followUser(userId: Int) async throws {
        try await remote.followUser(userId: userId)
    }

    func unFollowUser(userId: Int) async throws {
        try await remote.unFollowUser(userId: userId)
    }

    func markRead(id: Int) async throws {
        try await remote.markRead(id: id)
    }
}
