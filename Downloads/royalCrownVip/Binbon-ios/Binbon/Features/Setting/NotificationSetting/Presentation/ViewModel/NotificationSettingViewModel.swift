//
//  NotificationSettingViewModel.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI
import Combine

@MainActor
class NotificationSettingViewModel: ObservableObject {

    private let fetchNotificationsUseCase: FetchNotificationsUseCase
    private let markReadUseCase: MarkNotificationReadUseCase
    private let followUseCase: FollowFromNotificationUseCase
    private let unfollowUseCase: UnfollowFromNotificationUseCase
    private let fetchSettingsUseCase: FetchNotificationSettingsUseCase
    private let updateSettingsUseCase: UpdateNotificationSettingsUseCase
    private let soundOptionsUseCase: FetchNotificationSoundOptionsUseCase
    @Published var error: APIError?

    init(
        fetchNotificationsUseCase: FetchNotificationsUseCase,
        markReadUseCase: MarkNotificationReadUseCase,
        followUseCase: FollowFromNotificationUseCase,
        unfollowUseCase: UnfollowFromNotificationUseCase,
        fetchSettingsUseCase: FetchNotificationSettingsUseCase,
        updateSettingsUseCase: UpdateNotificationSettingsUseCase,
        soundOptionsUseCase: FetchNotificationSoundOptionsUseCase
    ) {
        self.fetchNotificationsUseCase = fetchNotificationsUseCase
        self.markReadUseCase = markReadUseCase
        self.followUseCase = followUseCase
        self.unfollowUseCase = unfollowUseCase
        self.fetchSettingsUseCase = fetchSettingsUseCase
        self.updateSettingsUseCase = updateSettingsUseCase
        self.soundOptionsUseCase = soundOptionsUseCase
    }

    /// Builds the use-case graph from a single repository — used by the app's DI
    /// factory and by tests that inject a mock repository.
    convenience init(repository: NotificationsRepositoryProtocol) {
        self.init(
            fetchNotificationsUseCase: FetchNotificationsUseCase(repository: repository),
            markReadUseCase: MarkNotificationReadUseCase(repository: repository),
            followUseCase: FollowFromNotificationUseCase(repository: repository),
            unfollowUseCase: UnfollowFromNotificationUseCase(repository: repository),
            fetchSettingsUseCase: FetchNotificationSettingsUseCase(repository: repository),
            updateSettingsUseCase: UpdateNotificationSettingsUseCase(repository: repository),
            soundOptionsUseCase: FetchNotificationSoundOptionsUseCase(repository: repository)
        )
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(repository: container.makeNotificationsRepository())
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }

    // MARK: - Dynamic feeds
  
    struct CategoryFeed {
        var items: [NotificationItem] = []
        var isLoading = false
    }

    @Published private(set) var feeds: [NotificationCategory: CategoryFeed] = [:]

    
    static let feedCategories: [NotificationCategory] = [
        .followers,
        .commentsLikes,
        .privateMessages,
        .liveStreams,
        .newStories,
        .competitionsGifts
    ]

    func items(for category: NotificationCategory) -> [NotificationItem] {
        feeds[category]?.items ?? []
    }

    func isLoading(_ category: NotificationCategory) -> Bool {
        feeds[category]?.isLoading ?? false
    }

  
    @Published var isLoading = false

    @Published var allNotificationsEnabled = false
    @Published var showInNotificationCenter = false
    @Published var musicEnabled = false
    @Published var showOnLockScreen = false

    @Published var vibrateWhileRinging = false
    @Published var ringtone: String?
    @Published var notificationSound: String?
    @Published var systemSound: String?

    @Published var ringtoneOptions: [String] = []
    @Published var notificationOptions: [String] = []
    @Published var systemOptions: [String] = []

    private var loadedSettings: NotificationSettingsResponse?

    // MARK: - Private-messages header selection (UI-only)
    @Published var isAllMessagesSelected = false

    func toggleSelectAllMessages() {
        isAllMessagesSelected.toggle()
    }

    // MARK: - Loading
    // The `Task`-wrapped methods are the fire-and-forget entry points used by the
    // view; each delegates to an `await`-able core so the logic can be unit tested
    // deterministically.

    func fetchAll() {
        Task { await fetchAllAsync() }
    }

    func fetchAllAsync() async {
        await withTaskGroup(of: Void.self) { group in
            for category in Self.feedCategories {
                group.addTask { await self.fetch(category) }
            }
        }
    }

    func fetch(_ category: NotificationCategory) async {
        feeds[category, default: .init()].isLoading = true

        do {
            let feed = try await fetchNotificationsUseCase.execute(category: category)
            feeds[category] = CategoryFeed(items: feed.items, isLoading: false)
        } catch {
            feeds[category, default: .init()].isLoading = false
            self.error = asAPIError(error)
        }
    }

    // MARK: - Actions

    func followBack(_ item: NotificationItem) {
        Task { await followBackAsync(item) }
    }

    func followBackAsync(_ item: NotificationItem) async {
        guard let userId = item.followUserId else { return }
        do {
            try await followUseCase.execute(userId: userId)
            Toaster.shared.show(.success(), "follow".localized)
            await fetch(.followers)
        } catch {
            self.error = asAPIError(error)
        }
    }

    func unfollow(_ item: NotificationItem) {
        Task { await unfollowAsync(item) }
    }

    func unfollowAsync(_ item: NotificationItem) async {
        guard let userId = item.followUserId else { return }
        do {
            try await unfollowUseCase.execute(userId: userId)
            Toaster.shared.show(.success(), "unfollow".localized)
            await fetch(.followers)
        } catch {
            self.error = asAPIError(error)
        }
    }

    func markRead(_ item: NotificationItem, in category: NotificationCategory) {
        Task { await markReadAsync(item, in: category) }
    }

    func markReadAsync(_ item: NotificationItem, in category: NotificationCategory) async {
        do {
            try await markReadUseCase.execute(id: item.id)
            await fetch(category)
        } catch {
            self.error = asAPIError(error)
        }
    }

    func markAllRead(in category: NotificationCategory) {
        Task { await markAllReadAsync(in: category) }
    }

    func markAllReadAsync(in category: NotificationCategory) async {
        let unread = items(for: category).filter { $0.isUnread }
        guard !unread.isEmpty else { return }
        await withTaskGroup(of: Void.self) { group in
            for item in unread {
                group.addTask { try? await self.markReadUseCase.execute(id: item.id) }
            }
        }
        await fetch(category)
    }

    // MARK: - Settings (general + sound)

    func fetchSettings() {
        Task { await fetchSettingsAsync() }
    }

    func fetchSettingsAsync() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let settings = try await fetchSettingsUseCase.execute()
            applySettings(settings)
        } catch {
            self.error = asAPIError(error)
        }
    }

    func fetchSoundOptions() {
        Task { await fetchSoundOptionsAsync() }
    }

    func fetchSoundOptionsAsync() async {
        do {
            let options = try await soundOptionsUseCase.execute()
            ringtoneOptions = options?.notifyRingtone ?? []
            notificationOptions = options?.notifyNotificationSound ?? []
            systemOptions = options?.notifySystemSound ?? []
        } catch {
            self.error = asAPIError(error)
        }
    }

    func saveSettings() {
        Task { await saveSettingsAsync() }
    }

    func saveSettingsAsync() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let request = NotificationSettingsRequest(
            general: .init(
                notifyAll: allNotificationsEnabled,
                notifyInNotificationCenter: showInNotificationCenter,
                notifyMusic: musicEnabled,
                notifyLockScreen: showOnLockScreen
            ),
            sound: .init(
                notifyVibrationEnabled: vibrateWhileRinging,
                notifyRingtone: ringtone,
                notifyNotificationSound: notificationSound,
                notifySystemSound: systemSound
            )
        )

        do {
            _ = try await updateSettingsUseCase.execute(request: request)
            Toaster.shared.show(.success(), "notification_settings_updated".localized)
            AppRouter.shared.back()
        } catch {
            self.error = asAPIError(error)
        }
    }

    func settingsUnchanged() -> Bool {
        guard let s = loadedSettings else { return true }
        return (s.general?.notifyAll ?? false) == allNotificationsEnabled
            && (s.general?.notifyInNotificationCenter ?? false) == showInNotificationCenter
            && (s.general?.notifyMusic ?? false) == musicEnabled
            && (s.general?.notifyLockScreen ?? false) == showOnLockScreen
            && (s.sound?.notifyVibrationEnabled ?? false) == vibrateWhileRinging
            && s.sound?.notifyRingtone == ringtone
            && s.sound?.notifyNotificationSound == notificationSound
            && s.sound?.notifySystemSound == systemSound
    }

    private func applySettings(_ data: NotificationSettingsResponse?) {
        loadedSettings = data
        allNotificationsEnabled = data?.general?.notifyAll ?? false
        showInNotificationCenter = data?.general?.notifyInNotificationCenter ?? false
        musicEnabled = data?.general?.notifyMusic ?? false
        showOnLockScreen = data?.general?.notifyLockScreen ?? false
        vibrateWhileRinging = data?.sound?.notifyVibrationEnabled ?? false
        ringtone = data?.sound?.notifyRingtone
        notificationSound = data?.sound?.notifyNotificationSound
        systemSound = data?.sound?.notifySystemSound
    }
}
