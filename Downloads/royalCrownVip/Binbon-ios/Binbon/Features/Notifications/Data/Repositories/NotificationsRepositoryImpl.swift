//
//  NotificationsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `NotificationsRepositoryProtocol`, driving the remote
//  data source.
//

import Foundation

final class NotificationsRepositoryImpl: NotificationsRepositoryProtocol {

    private let remote: NotificationsRemoteDataSource

    init(remote: NotificationsRemoteDataSource) {
        self.remote = remote
    }

    func fetchNotifications(category: NotificationCategory, page: Int, perPage: Int) async throws -> NotificationFeedResponse {
        try await remote.fetchNotifications(category: category, page: page, perPage: perPage)
    }

    func markRead(id: Int) async throws {
        try await remote.markRead(id: id)
    }

    func followUser(userId: Int) async throws {
        try await remote.followUser(userId: userId)
    }

    func unFollowUser(userId: Int) async throws {
        try await remote.unFollowUser(userId: userId)
    }

    func fetchSettings() async throws -> NotificationSettingsResponse? {
        try await remote.fetchSettings()
    }

    func updateSettings(request: NotificationSettingsRequest) async throws -> NotificationSettingsResponse? {
        try await remote.updateSettings(request: request)
    }

    func soundOptions() async throws -> NotificationSoundOptions? {
        try await remote.soundOptions()
    }
}
