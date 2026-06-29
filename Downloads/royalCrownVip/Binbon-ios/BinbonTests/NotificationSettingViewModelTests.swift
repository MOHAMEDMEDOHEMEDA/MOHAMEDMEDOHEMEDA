//
//  NotificationSettingViewModelTests.swift
//  BinbonTests
//
//  Behavioural tests for NotificationSettingViewModel using a mock repo. The
//  view model's fire-and-forget methods delegate to `…Async` cores, which these
//  tests await directly for determinism.
//

import XCTest
@testable import Binbon

@MainActor
final class NotificationSettingViewModelTests: XCTestCase {

    private var mock: MockNotificationRepo!
    private var vm: NotificationSettingViewModel!

    override func setUp() {
        super.setUp()
        mock = MockNotificationRepo()
        vm = NotificationSettingViewModel(repository: mock)
    }

    override func tearDown() {
        mock = nil
        vm = nil
        super.tearDown()
    }

    // MARK: - Helpers
    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    private func feed(_ json: String) throws -> Result<NotificationFeedResponse, APIError> {
        .success(try XCTUnwrap(try decode(BaseResponse<NotificationFeedResponse>.self, json).data))
    }

    private let settingsJSON = """
    {
        "status": true, "message": "ok",
        "data": {
            "general": { "notify_all": true, "notify_in_notification_center": true, "notify_music": false, "notify_lock_screen": false },
            "sound": { "notify_vibration_enabled": true, "notify_ringtone": "Orbit", "notify_notification_sound": null, "notify_system_sound": null }
        }
    }
    """

    // MARK: - Settings load
    func testFetchSettingsAppliesValues() async throws {
        mock.settingsResult = .success(try decode(BaseResponse<NotificationSettingsResponse>.self, settingsJSON).data)

        await vm.fetchSettingsAsync()

        XCTAssertTrue(vm.allNotificationsEnabled)
        XCTAssertTrue(vm.showInNotificationCenter)
        XCTAssertFalse(vm.musicEnabled)
        XCTAssertFalse(vm.showOnLockScreen)
        XCTAssertTrue(vm.vibrateWhileRinging)
        XCTAssertEqual(vm.ringtone, "Orbit")
        XCTAssertNil(vm.notificationSound)
        XCTAssertFalse(vm.isLoading)               // overlay cleared
        XCTAssertNil(vm.error)
    }

    func testFetchSettingsFailureSetsError() async {
        mock.settingsResult = .failure(APIError(type: .network))
        await vm.fetchSettingsAsync()
        XCTAssertNotNil(vm.error)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Change detection / Save button enablement
    func testSettingsUnchangedTrueBeforeLoad() {
        XCTAssertTrue(vm.settingsUnchanged())      // no snapshot yet → Save disabled
    }

    func testSettingsUnchangedAfterLoadThenDirtyOnChange() async throws {
        mock.settingsResult = .success(try decode(BaseResponse<NotificationSettingsResponse>.self, settingsJSON).data)
        await vm.fetchSettingsAsync()

        XCTAssertTrue(vm.settingsUnchanged())      // matches loaded snapshot

        vm.musicEnabled.toggle()
        XCTAssertFalse(vm.settingsUnchanged())     // a toggle change dirties the form

        vm.musicEnabled.toggle()
        XCTAssertTrue(vm.settingsUnchanged())      // reverted → clean again

        vm.systemSound = "Aurora"
        XCTAssertFalse(vm.settingsUnchanged())     // a sound change also dirties
    }

    // MARK: - Sound options
    func testFetchSoundOptionsPopulatesDropdowns() async throws {
        let json = """
        { "status": true, "data": { "notify_ringtone": ["Orbit","Pulse"], "notify_notification_sound": ["Echo"], "notify_system_sound": ["Galaxy","Aurora"] } }
        """
        mock.soundOptionsResult = .success(try decode(BaseResponse<NotificationSoundOptions>.self, json).data)

        await vm.fetchSoundOptionsAsync()

        XCTAssertEqual(vm.ringtoneOptions, ["Orbit", "Pulse"])
        XCTAssertEqual(vm.notificationOptions, ["Echo"])
        XCTAssertEqual(vm.systemOptions, ["Galaxy", "Aurora"])
    }

    // MARK: - Save
    func testSaveSendsCurrentFormState() async throws {
        mock.settingsResult = .success(try decode(BaseResponse<NotificationSettingsResponse>.self, settingsJSON).data)
        mock.updateResult = .success(nil)
        await vm.fetchSettingsAsync()

        vm.musicEnabled = true
        vm.systemSound = "Galaxy"

        await vm.saveSettingsAsync()

        let request = try XCTUnwrap(mock.updatedRequests.last)
        XCTAssertEqual(request.general?.notifyAll, true)
        XCTAssertEqual(request.general?.notifyMusic, true)         // edited value sent
        XCTAssertEqual(request.general?.notifyLockScreen, false)
        XCTAssertEqual(request.sound?.notifyVibrationEnabled, true)
        XCTAssertEqual(request.sound?.notifyRingtone, "Orbit")
        XCTAssertEqual(request.sound?.notifySystemSound, "Galaxy")  // edited value sent
        XCTAssertNil(vm.error)
        XCTAssertFalse(vm.isLoading)
    }

    func testSaveFailureSetsError() async {
        mock.updateResult = .failure(APIError(type: .backend, code: 500, message: "boom"))
        await vm.saveSettingsAsync()
        XCTAssertNotNil(vm.error)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - Feed loading
    func testFetchPopulatesFeedAndClearsLoading() async throws {
        mock.feedResult = try feed("""
        { "status": true, "data": { "items": [ { "id": 1, "title": "x" } ], "pagination": null } }
        """)

        await vm.fetch(.followers)

        XCTAssertEqual(vm.items(for: .followers).count, 1)
        XCTAssertFalse(vm.isLoading(.followers))
        XCTAssertNil(vm.error)
    }

    func testFetchFailureSetsErrorAndClearsLoading() async {
        mock.feedResult = .failure(APIError(type: .network))
        await vm.fetch(.commentsLikes)
        XCTAssertNotNil(vm.error)
        XCTAssertFalse(vm.isLoading(.commentsLikes))
    }

    func testFetchAllRequestsEveryFeedCategory() async {
        await vm.fetchAllAsync()
        XCTAssertEqual(Set(mock.fetchedCategories), Set(NotificationSettingViewModel.feedCategories))
    }

    // MARK: - Follow / unfollow
    func testFollowBackCallsRepoThenRefreshesFollowers() async throws {
        let item = try decode(NotificationItem.self, #"{ "id": 1, "action": { "payload": { "user_id": 7 } } }"#)

        await vm.followBackAsync(item)

        XCTAssertEqual(mock.followedUserIds, [7])
        XCTAssertTrue(mock.fetchedCategories.contains(.followers))  // refresh after follow
        XCTAssertNil(vm.error)
    }

    func testFollowBackWithoutUserIdDoesNothing() async throws {
        let item = try decode(NotificationItem.self, #"{ "id": 1 }"#)
        await vm.followBackAsync(item)
        XCTAssertTrue(mock.followedUserIds.isEmpty)
        XCTAssertFalse(mock.fetchedCategories.contains(.followers))
    }

    func testUnfollowCallsRepoThenRefreshes() async throws {
        let item = try decode(NotificationItem.self, #"{ "id": 1, "actor_id": 9 }"#)
        await vm.unfollowAsync(item)
        XCTAssertEqual(mock.unfollowedUserIds, [9])               // falls back to actor_id
        XCTAssertTrue(mock.fetchedCategories.contains(.followers))
    }

    // MARK: - Mark read
    func testMarkAllReadOnlyMarksUnreadItems() async throws {
        mock.feedResultsByCategory[.privateMessages] = try feed("""
        {
            "status": true,
            "data": { "items": [
                { "id": 1, "unread": true },
                { "id": 2, "unread": false },
                { "id": 3, "unread": true }
            ], "pagination": null }
        }
        """)
        await vm.fetch(.privateMessages)          // seed the feed

        await vm.markAllReadAsync(in: .privateMessages)

        XCTAssertEqual(Set(mock.markReadIds), [1, 3])   // read item (2) skipped
    }

    func testMarkReadCallsRepoAndRefreshes() async throws {
        let item = try decode(NotificationItem.self, #"{ "id": 55, "unread": true }"#)
        await vm.markReadAsync(item, in: .privateMessages)
        XCTAssertEqual(mock.markReadIds, [55])
        XCTAssertTrue(mock.fetchedCategories.contains(.privateMessages))
    }
}
