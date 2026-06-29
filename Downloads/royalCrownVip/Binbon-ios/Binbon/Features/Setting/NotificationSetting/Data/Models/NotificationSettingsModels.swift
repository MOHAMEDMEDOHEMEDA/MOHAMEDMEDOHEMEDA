//
//  NotificationSettingsModels.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//
//

import Foundation

// MARK: - Settings response
struct NotificationSettingsResponse: Decodable {
    let general: GeneralSettings?
    let sound: SoundSettings?

    struct GeneralSettings: Decodable {
        let notifyAll: Bool?
        let notifyInNotificationCenter: Bool?
        let notifyMusic: Bool?
        let notifyLockScreen: Bool?

        enum CodingKeys: String, CodingKey {
            case notifyAll = "notify_all"
            case notifyInNotificationCenter = "notify_in_notification_center"
            case notifyMusic = "notify_music"
            case notifyLockScreen = "notify_lock_screen"
        }
    }

    struct SoundSettings: Decodable {
        let notifyVibrationEnabled: Bool?
        let notifyRingtone: String?
        let notifyNotificationSound: String?
        let notifySystemSound: String?

        enum CodingKeys: String, CodingKey {
            case notifyVibrationEnabled = "notify_vibration_enabled"
            case notifyRingtone = "notify_ringtone"
            case notifyNotificationSound = "notify_notification_sound"
            case notifySystemSound = "notify_system_sound"
        }
    }
}

// MARK: - Settings update request (partial, section-based)
struct NotificationSettingsRequest: Encodable {
    var general: General?
    var sound: Sound?

    struct General: Encodable {
        var notifyAll: Bool?
        var notifyInNotificationCenter: Bool?
        var notifyMusic: Bool?
        var notifyLockScreen: Bool?

        enum CodingKeys: String, CodingKey {
            case notifyAll = "notify_all"
            case notifyInNotificationCenter = "notify_in_notification_center"
            case notifyMusic = "notify_music"
            case notifyLockScreen = "notify_lock_screen"
        }
    }

    struct Sound: Encodable {
        var notifyVibrationEnabled: Bool?
        var notifyRingtone: String?
        var notifyNotificationSound: String?
        var notifySystemSound: String?

        enum CodingKeys: String, CodingKey {
            case notifyVibrationEnabled = "notify_vibration_enabled"
            case notifyRingtone = "notify_ringtone"
            case notifyNotificationSound = "notify_notification_sound"
            case notifySystemSound = "notify_system_sound"
        }
    }
}

// MARK: - Sound options
struct NotificationSoundOptions: Decodable {
    let notifyRingtone: [String]?
    let notifyNotificationSound: [String]?
    let notifySystemSound: [String]?

    enum CodingKeys: String, CodingKey {
        case notifyRingtone = "notify_ringtone"
        case notifyNotificationSound = "notify_notification_sound"
        case notifySystemSound = "notify_system_sound"
    }
}
