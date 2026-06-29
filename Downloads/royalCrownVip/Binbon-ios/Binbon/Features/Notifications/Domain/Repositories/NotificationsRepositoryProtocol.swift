//
//  NotificationsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — notifications boundary the use cases depend on. Returns entities
//  and throws `APIError`; the settings endpoints may legitimately resolve with no
//  payload, so those return an optional entity.
//

import Foundation

protocol NotificationsRepositoryProtocol {
    func fetchNotifications(category: NotificationCategory, page: Int, perPage: Int) async throws -> NotificationFeedResponse
    func markRead(id: Int) async throws
    func followUser(userId: Int) async throws
    func unFollowUser(userId: Int) async throws
    func fetchSettings() async throws -> NotificationSettingsResponse?
    func updateSettings(request: NotificationSettingsRequest) async throws -> NotificationSettingsResponse?
    func soundOptions() async throws -> NotificationSoundOptions?
}

extension NotificationsRepositoryProtocol {
    /// Convenience used by the view model — first page, default size.
    func fetchNotifications(category: NotificationCategory) async throws -> NotificationFeedResponse {
        try await fetchNotifications(category: category, page: 1, perPage: 20)
    }
}
