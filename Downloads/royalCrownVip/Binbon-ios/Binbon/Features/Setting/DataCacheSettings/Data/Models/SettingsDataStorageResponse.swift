//
//  SettingsDataStorageResponse.swift
//  Binbon
//
//  Created by Husayn on 03/06/2026.
//

import Foundation

struct DataStorageSettingsResponse: Codable {
    let storage: StorageSetting
    let videoDownload: VideoDownload
    let dataSaver: DataSaver
    let actions: Actions

    enum CodingKeys: String, CodingKey {
        case storage
        case videoDownload = "video_download"
        case dataSaver = "data_saver"
        case actions
    }
}

struct StorageSetting: Codable {
    let cacheSizeMB: Double
    let totalStorageMB: Int

    enum CodingKeys: String, CodingKey {
        case cacheSizeMB = "cache_size_mb"
        case totalStorageMB = "total_storage_mb"
    }
}

struct VideoDownload: Codable {
    let defaultQuality: String
    let effectiveQuality: String?
    let allowedQualities: [String]

    enum CodingKeys: String, CodingKey {
        case defaultQuality = "default_quality"
        case effectiveQuality = "effective_quality"
        case allowedQualities = "allowed_qualities"
    }
}

struct DataSaver: Codable {
    let enabled: Bool
    let disableAutoplay: Bool

    enum CodingKeys: String, CodingKey {
        case enabled
        case disableAutoplay = "disable_autoplay"
    }
}

struct Actions: Codable {
    let clearCacheEndpoint: String
    let personalDataExportEndpoint: String
    let deleteAccountEndpoint: String

    enum CodingKeys: String, CodingKey {
        case clearCacheEndpoint = "clear_cache_endpoint"
        case personalDataExportEndpoint = "personal_data_export_endpoint"
        case deleteAccountEndpoint = "delete_account_endpoint"
    }
}
