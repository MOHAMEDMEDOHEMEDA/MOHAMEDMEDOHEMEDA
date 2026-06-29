//
//  NotificationModelTests.swift
//  BinbonTests
//
//  Decoding + computed-property tests for the notification DTOs against the real
//  backend payload shapes.
//

import XCTest
@testable import Binbon

final class NotificationModelTests: XCTestCase {

    private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    // MARK: - Settings response (GET /api/user/notification-settings)
    func testDecodeSettingsResponse() throws {
        let json = """
        {
            "status": true,
            "message": "Notification settings fetched successfully",
            "data": {
                "general": {
                    "notify_all": true,
                    "notify_in_notification_center": true,
                    "notify_music": false,
                    "notify_lock_screen": false
                },
                "sound": {
                    "notify_vibration_enabled": true,
                    "notify_ringtone": null,
                    "notify_notification_sound": null,
                    "notify_system_sound": null
                }
            }
        }
        """

        let response = try decode(BaseResponse<NotificationSettingsResponse>.self, json)
        XCTAssertEqual(response.status, true)
        let data = try XCTUnwrap(response.data)
        XCTAssertEqual(data.general?.notifyAll, true)
        XCTAssertEqual(data.general?.notifyInNotificationCenter, true)
        XCTAssertEqual(data.general?.notifyMusic, false)
        XCTAssertEqual(data.general?.notifyLockScreen, false)
        XCTAssertEqual(data.sound?.notifyVibrationEnabled, true)
        XCTAssertNil(data.sound?.notifyRingtone)
        XCTAssertNil(data.sound?.notifyNotificationSound)
        XCTAssertNil(data.sound?.notifySystemSound)
    }

    // MARK: - Sound options (GET /api/user/notification-sound-options)
    func testDecodeSoundOptions() throws {
        let json = """
        {
            "status": true,
            "message": "Notification sound options fetched successfully",
            "data": {
                "notify_ringtone": ["Gimme Shelter", "Orbit", "Pulse"],
                "notify_notification_sound": ["Gimme Shelter", "Ripple", "Echo"],
                "notify_system_sound": ["Galaxy", "Aurora", "Classic"]
            }
        }
        """

        let response = try decode(BaseResponse<NotificationSoundOptions>.self, json)
        let data = try XCTUnwrap(response.data)
        XCTAssertEqual(data.notifyRingtone, ["Gimme Shelter", "Orbit", "Pulse"])
        XCTAssertEqual(data.notifyNotificationSound, ["Gimme Shelter", "Ripple", "Echo"])
        XCTAssertEqual(data.notifySystemSound, ["Galaxy", "Aurora", "Classic"])
    }

    // MARK: - Feed response (GET /api/user/notifications?category=…)
    func testDecodeFeedResponseAndItem() throws {
        let json = """
        {
            "status": true,
            "message": "ok",
            "data": {
                "items": [
                    {
                        "id": 42,
                        "type": 1,
                        "category": "followers",
                        "title": "Hamza followed you",
                        "actor_id": 7,
                        "target_id": 99,
                        "timestamp": "2026-06-04T10:00:00.000000Z",
                        "time_ago": "2 hours ago",
                        "is_following": false,
                        "read_status": false,
                        "unread": true,
                        "actor": {
                            "id": 7,
                            "username": "hamza",
                            "fullname": "Hamza Syria",
                            "profile_photo": "uploads/hamza.png"
                        },
                        "action": {
                            "type": "follow",
                            "method": "POST",
                            "endpoint": "api/user/followUser",
                            "payload": { "user_id": 7 }
                        }
                    }
                ],
                "pagination": { "current_page": 1, "per_page": 20, "total": 1, "last_page": 1, "has_more": false }
            }
        }
        """

        let response = try decode(BaseResponse<NotificationFeedResponse>.self, json)
        let item = try XCTUnwrap(response.data?.items.first)
        XCTAssertEqual(item.id, 42)
        XCTAssertEqual(item.category, "followers")
        XCTAssertEqual(item.actorName, "Hamza Syria")
        XCTAssertEqual(item.timeAgo, "2 hours ago")
        XCTAssertEqual(item.followUserId, 7)            // from action.payload.user_id
        XCTAssertTrue(item.isUnread)
        XCTAssertEqual(response.data?.pagination?.hasMore, false)
    }

    // MARK: - Computed properties
    func testFollowUserIdFallsBackToActorId() throws {
        // No action payload → falls back to actor_id.
        let json = """
        { "id": 1, "actor_id": 55, "action": { "type": "follow", "payload": null } }
        """
        let item = try decode(NotificationItem.self, json)
        XCTAssertEqual(item.followUserId, 55)
    }

    func testIsUnreadPrefersUnreadFlagThenReadStatusThenDefault() throws {
        let unread = try decode(NotificationItem.self, #"{ "id": 1, "unread": true }"#)
        XCTAssertTrue(unread.isUnread)

        let read = try decode(NotificationItem.self, #"{ "id": 2, "unread": false }"#)
        XCTAssertFalse(read.isUnread)

        let viaReadStatus = try decode(NotificationItem.self, #"{ "id": 3, "read_status": true }"#)
        XCTAssertFalse(viaReadStatus.isUnread)        // read_status true → read

        let defaultUnread = try decode(NotificationItem.self, #"{ "id": 4 }"#)
        XCTAssertTrue(defaultUnread.isUnread)          // nothing set → defaults unread
    }

    func testBadgeHeuristics() throws {
        let like = try decode(NotificationItem.self, #"{ "id": 1, "action": { "type": "post_like" } }"#)
        XCTAssertTrue(like.isLikeAction)

        let comment = try decode(NotificationItem.self, #"{ "id": 2, "action": { "type": "comment" } }"#)
        XCTAssertFalse(comment.isLikeAction)

        let win = try decode(NotificationItem.self, #"{ "id": 3, "title": "You won the PK competition!" }"#)
        XCTAssertTrue(win.isWinAction)

        let gift = try decode(NotificationItem.self, #"{ "id": 4, "title": "sent you a gift" }"#)
        XCTAssertFalse(gift.isWinAction)
    }

    func testAvatarURLPrefixesRelativePaths() throws {
        let relative = try decode(NotificationItem.self, #"{ "id": 1, "actor": { "profile_photo": "uploads/a.png" } }"#)
        XCTAssertEqual(relative.avatarURL, API.baseUrl + "uploads/a.png")

        let absolute = try decode(NotificationItem.self, #"{ "id": 2, "actor": { "profile_photo": "https://cdn/x.png" } }"#)
        XCTAssertEqual(absolute.avatarURL, "https://cdn/x.png")

        let none = try decode(NotificationItem.self, #"{ "id": 3, "actor": { "profile_photo": "" } }"#)
        XCTAssertNil(none.avatarURL)
    }

    // MARK: - Category raw values match the API contract
    func testCategoryRawValues() {
        XCTAssertEqual(NotificationCategory.commentsLikes.rawValue, "comments_likes")
        XCTAssertEqual(NotificationCategory.privateMessages.rawValue, "private_messages")
        XCTAssertEqual(NotificationCategory.liveStreams.rawValue, "live_streams")
        XCTAssertEqual(NotificationCategory.newStories.rawValue, "new_stories")
        XCTAssertEqual(NotificationCategory.competitionsGifts.rawValue, "competitions_gifts")
        XCTAssertEqual(NotificationCategory.closeFriends.rawValue, "close_friends")
        XCTAssertEqual(NotificationCategory.followers.rawValue, "followers")
    }
}
