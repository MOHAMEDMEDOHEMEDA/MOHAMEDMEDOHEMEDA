//
//  MockNotificationRepo.swift
//  BinbonTests
//
//  In-memory stand-in for the notifications repository used to drive the view
//  model in tests without touching the network. Each endpoint returns a
//  configurable result (entity or error) and records the arguments it was called
//  with.
//

import Foundation
@testable import Binbon

final class MockNotificationRepo: NotificationsRepositoryProtocol {

    // MARK: - Configurable results
    var feedResult: Result<NotificationFeedResponse, APIError> =
        .success(NotificationFeedResponse(items: [], pagination: nil))
    /// Per-category override; falls back to `feedResult` when absent.
    var feedResultsByCategory: [NotificationCategory: Result<NotificationFeedResponse, APIError>] = [:]

    var markReadResult: Result<Void, APIError> = .success(())
    var followResult: Result<Void, APIError> = .success(())
    var unfollowResult: Result<Void, APIError> = .success(())

    var settingsResult: Result<NotificationSettingsResponse?, APIError> = .success(nil)
    var updateResult: Result<NotificationSettingsResponse?, APIError> = .success(nil)
    var soundOptionsResult: Result<NotificationSoundOptions?, APIError> = .success(nil)

    // MARK: - Recorded calls
    private(set) var fetchedCategories: [NotificationCategory] = []
    private(set) var markReadIds: [Int] = []
    private(set) var followedUserIds: [Int] = []
    private(set) var unfollowedUserIds: [Int] = []
    private(set) var updatedRequests: [NotificationSettingsRequest] = []
    private(set) var fetchSettingsCount = 0
    private(set) var soundOptionsCount = 0

    // MARK: - NotificationsRepositoryProtocol
    func fetchNotifications(category: NotificationCategory, page: Int, perPage: Int) async throws -> NotificationFeedResponse {
        fetchedCategories.append(category)
        return try (feedResultsByCategory[category] ?? feedResult).get()
    }

    func markRead(id: Int) async throws {
        markReadIds.append(id)
        try markReadResult.get()
    }

    func followUser(userId: Int) async throws {
        followedUserIds.append(userId)
        try followResult.get()
    }

    func unFollowUser(userId: Int) async throws {
        unfollowedUserIds.append(userId)
        try unfollowResult.get()
    }

    func fetchSettings() async throws -> NotificationSettingsResponse? {
        fetchSettingsCount += 1
        return try settingsResult.get()
    }

    func updateSettings(request: NotificationSettingsRequest) async throws -> NotificationSettingsResponse? {
        updatedRequests.append(request)
        return try updateResult.get()
    }

    func soundOptions() async throws -> NotificationSoundOptions? {
        soundOptionsCount += 1
        return try soundOptionsResult.get()
    }
}
