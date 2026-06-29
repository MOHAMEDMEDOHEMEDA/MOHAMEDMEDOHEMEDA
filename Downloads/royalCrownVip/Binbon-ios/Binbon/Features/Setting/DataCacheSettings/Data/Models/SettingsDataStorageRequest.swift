//
//  SettingsDataStorageRequest.swift
//  Binbon
//
//  Created by Husayn on 03/06/2026.
//

import Foundation

struct UpdateDataStorageSettingsRequest: Encodable {
    let defaultQuality: String?
    let dataSaver: Bool?

    enum CodingKeys: String, CodingKey {
        case defaultQuality = "default_quality"
        case dataSaver = "data_saver"
    }
}
