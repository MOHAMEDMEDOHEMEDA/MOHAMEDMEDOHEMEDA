//
//  AdsSettingModel.swift
//  Binbon
//
//  Created by Mahmoud Abdelhady on 18/06/2026.
//

import Foundation

struct AdType: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let key: String
    let title: String
    var enabled: Bool

    enum CodingKeys: String, CodingKey {
        case id, key, title, enabled
    }
}

struct AdsSettingResponse: Codable {
    let adTypes: [AdType]

    enum CodingKeys: String, CodingKey {
        case adTypes = "ad_types"
    }
}

struct AdsSettingRequest: Codable {
    let adTypes: [AdType]

    enum CodingKeys: String, CodingKey {
        case adTypes = "ad_types"
    }
}
