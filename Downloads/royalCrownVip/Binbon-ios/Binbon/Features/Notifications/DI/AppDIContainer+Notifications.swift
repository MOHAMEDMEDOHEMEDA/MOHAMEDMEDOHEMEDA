//
//  AppDIContainer+Notifications.swift
//  Binbon
//
//  Composition root — Notifications feature factories.
//

import Foundation

extension AppDIContainer {

    func makeNotificationsRemoteDataSource() -> NotificationsRemoteDataSource {
        MockNotificationsRemoteDataSource()
    }

    func makeNotificationsRepository() -> NotificationsRepositoryProtocol {
        NotificationsRepositoryImpl(remote: makeNotificationsRemoteDataSource())
    }

    @MainActor
    func makeNotificationSettingViewModel() -> NotificationSettingViewModel {
        NotificationSettingViewModel(repository: makeNotificationsRepository())
    }
}
