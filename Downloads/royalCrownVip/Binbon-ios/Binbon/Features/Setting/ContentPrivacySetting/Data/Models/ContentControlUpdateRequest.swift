//
//  ContentControlUpdateRequest.swift
//  Binbon
//
//  Created by Ramez Hamdy on 03/06/2026.
//

import Foundation

struct ContentControlUpdateRequest: Encodable {
    let categoryIds: [Int]
    let isUnder18: Bool
    let kidsModeEnabled: Bool
    let filterInappropriateContent: Bool
    let blockedKeywords: String

    enum CodingKeys: String, CodingKey {
        case categoryIds = "category_ids"
        case isUnder18 = "is_under_18"
        case kidsModeEnabled = "kids_mode_enabled"
        case filterInappropriateContent = "filter_inappropriate_content"
        case blockedKeywords = "blocked_keywords"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !categoryIds.isEmpty {
            try container.encode(categoryIds, forKey: .categoryIds)
        }
        try container.encode(isUnder18, forKey: .isUnder18)
        try container.encode(kidsModeEnabled, forKey: .kidsModeEnabled)
        try container.encode(filterInappropriateContent, forKey: .filterInappropriateContent)
        try container.encode(blockedKeywords, forKey: .blockedKeywords)
    }
}
