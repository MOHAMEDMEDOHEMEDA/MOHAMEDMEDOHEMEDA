//
//  NotificationsUseCases.swift
//  Binbon
//
//  Domain layer — notification feed + settings use cases.
//

import Foundation

struct FetchNotificationsUseCase {
    private let repository: NotificationsRepositoryProtocol
    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }
    func execute(category: NotificationCategory) async throws -> NotificationFeedResponse {
        try await repository.fetchNotifications(category: category)
    }
}

struct MarkNotificationReadUseCase {
    private let repository: NotificationsRepositoryProtocol
    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }
    func execute(id: Int) async throws {
        try await repository.markRead(id: id)
    }
}

struct FollowFromNotificationUseCase {
    private let repository: NotificationsRepositoryProtocol
    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }
    func execute(userId: Int) async throws {
        try await repository.followUser(userId: userId)
    }
}

struct UnfollowFromNotificationUseCase {
    private let repository: NotificationsRepositoryProtocol
    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }
    func execute(userId: Int) async throws {
        try await repository.unFollowUser(userId: userId)
    }
}

struct FetchNotificationSettingsUseCase {
    private let repository: NotificationsRepositoryProtocol
    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> NotificationSettingsResponse? {
        try await repository.fetchSettings()
    }
}

struct UpdateNotificationSettingsUseCase {
    private let repository: NotificationsRepositoryProtocol
    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }
    func execute(request: NotificationSettingsRequest) async throws -> NotificationSettingsResponse? {
        try await repository.updateSettings(request: request)
    }
}

struct FetchNotificationSoundOptionsUseCase {
    private let repository: NotificationsRepositoryProtocol
    init(repository: NotificationsRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> NotificationSoundOptions? {
        try await repository.soundOptions()
    }
}
