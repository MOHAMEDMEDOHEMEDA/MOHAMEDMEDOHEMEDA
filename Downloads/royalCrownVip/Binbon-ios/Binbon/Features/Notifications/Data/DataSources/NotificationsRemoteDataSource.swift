//
//  NotificationsRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for notifications. Mock-backed during the
//  current pre-integration phase; returns domain entities.
//

import Foundation

protocol NotificationsRemoteDataSource {
    func fetchNotifications(category: NotificationCategory, page: Int, perPage: Int) async throws -> NotificationFeedResponse
    func markRead(id: Int) async throws
    func followUser(userId: Int) async throws
    func unFollowUser(userId: Int) async throws
    func fetchSettings() async throws -> NotificationSettingsResponse?
    func updateSettings(request: NotificationSettingsRequest) async throws -> NotificationSettingsResponse?
    func soundOptions() async throws -> NotificationSoundOptions?
}

// MARK: - Mock

struct MockNotificationsRemoteDataSource: NotificationsRemoteDataSource {

    func fetchNotifications(category: NotificationCategory, page: Int, perPage: Int) async throws -> NotificationFeedResponse {
        let envelope: BaseResponse<NotificationFeedResponse> = try Self.decode(Self.feedJSON)
        guard let feed = envelope.data else {
            throw APIError(type: .parsing, message: "Empty mock notification feed")
        }
        return feed
    }

    func markRead(id: Int) async throws {}
    func followUser(userId: Int) async throws {}
    func unFollowUser(userId: Int) async throws {}

    func fetchSettings() async throws -> NotificationSettingsResponse? {
        let envelope: BaseResponse<NotificationSettingsResponse> = try Self.decode(Self.settingsJSON)
        return envelope.data
    }

    func updateSettings(request: NotificationSettingsRequest) async throws -> NotificationSettingsResponse? {
        let envelope: BaseResponse<NotificationSettingsResponse> = try Self.decode(Self.settingsJSON)
        return envelope.data
    }

    func soundOptions() async throws -> NotificationSoundOptions? {
        let envelope: BaseResponse<NotificationSoundOptions> = try Self.decode(Self.soundJSON)
        return envelope.data
    }

    // MARK: - Helpers

    private static func decode<T: Decodable>(_ json: String) throws -> BaseResponse<T> {
        guard let data = json.data(using: .utf8) else {
            throw APIError(type: .parsing, message: "Invalid mock JSON")
        }
        do {
            return try JSONDecoder().decode(BaseResponse<T>.self, from: data)
        } catch {
            throw APIError(type: .parsing, message: "\(error)")
        }
    }

    private static let feedJSON = #"""
    {"status":true,"message":"OK","data":{
      "items":[
        {"id":1001,"type":1,"category":"comments_likes","title":"liked your photo","actor_id":501,"target_id":9001,"timestamp":"2026-06-15T09:42:00Z","time_ago":"2h","is_following":true,"read_status":false,"unread":true,"actor":{"id":501,"username":"sara_k","fullname":"Sara Khalil","profile_photo":"https://picsum.photos/seed/501/200"},"action":{"type":"like","method":"GET","endpoint":"/posts/9001","payload":{"user_id":501}}},
        {"id":1002,"type":2,"category":"comments_likes","title":"commented: \"Looks amazing!\"","actor_id":502,"target_id":9002,"timestamp":"2026-06-15T07:15:00Z","time_ago":"5h","is_following":false,"read_status":false,"unread":true,"actor":{"id":502,"username":"omar.dev","fullname":"Omar Nasser","profile_photo":"https://picsum.photos/seed/502/200"},"action":{"type":"comment","method":"GET","endpoint":"/posts/9002","payload":{"user_id":502}}},
        {"id":1003,"type":3,"category":"followers","title":"started following you","actor_id":503,"target_id":null,"timestamp":"2026-06-14T18:30:00Z","time_ago":"1d","is_following":false,"read_status":true,"unread":false,"actor":{"id":503,"username":"lina_m","fullname":"Lina Mansour","profile_photo":"https://picsum.photos/seed/503/200"},"action":{"type":"follow","method":"POST","endpoint":"/users/503/follow","payload":{"user_id":503}}},
        {"id":1004,"type":4,"category":"competitions_gifts","title":"You won the weekly competition!","actor_id":null,"target_id":7001,"timestamp":"2026-06-13T12:00:00Z","time_ago":"2d","is_following":null,"read_status":true,"unread":false,"actor":{"id":0,"username":"system","fullname":"Binbon","profile_photo":"https://picsum.photos/seed/777/200"},"action":{"type":"competition_win","method":"GET","endpoint":"/competitions/7001","payload":null}},
        {"id":1005,"type":5,"category":"live_streams","title":"is live now","actor_id":505,"target_id":6001,"timestamp":"2026-06-12T20:10:00Z","time_ago":"3d","is_following":true,"read_status":true,"unread":false,"actor":{"id":505,"username":"dj_yousef","fullname":"Yousef Adel","profile_photo":"https://picsum.photos/seed/505/200"},"action":{"type":"live_started","method":"GET","endpoint":"/live/6001","payload":{"user_id":505}}},
        {"id":1006,"type":0,"category":"system","title":"Welcome to Binbon — complete your profile to get started.","actor_id":null,"target_id":null,"timestamp":"2026-06-08T10:00:00Z","time_ago":"1w","is_following":null,"read_status":true,"unread":false,"actor":{"id":0,"username":"system","fullname":"Binbon","profile_photo":"https://picsum.photos/seed/888/200"},"action":null}
      ],
      "pagination":{"current_page":1,"per_page":20,"total":6,"last_page":1,"has_more":false}
    }}
    """#

    private static let settingsJSON = #"""
    {"status":true,"message":"OK","data":{
      "general":{"notify_all":true,"notify_in_notification_center":true,"notify_music":false,"notify_lock_screen":true},
      "sound":{"notify_vibration_enabled":true,"notify_ringtone":"Chime","notify_notification_sound":"Pop","notify_system_sound":"Default"}
    }}
    """#

    private static let soundJSON = #"""
    {"status":true,"message":"OK","data":{
      "notify_ringtone":["Chime","Bell","Marimba","Radar","Beacon"],
      "notify_notification_sound":["Pop","Ding","Note","Tweet","Pulse"],
      "notify_system_sound":["Default","Silent","Classic","Soft"]
    }}
    """#
}
