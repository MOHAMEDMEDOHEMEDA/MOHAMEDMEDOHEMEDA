//
//  ContentControlSettings.swift
//  Binbon
//
//  Created by Ramez Hamdy on 03/06/2026.
//

import Foundation

struct ContentControlSettings: Codable {
    let contentTypes: ContentTypes?
    let age: AgeSettings?
    let kidsMode: KidsModeSettings?
    let safety: SafetySettings?

    enum CodingKeys: String, CodingKey {
        case contentTypes = "content_types"
        case age
        case kidsMode = "kids_mode"
        case safety
    }
}

struct ContentTypes: Codable {
    let available: [ContentCategory]?
    let selected: [ContentCategory]?
    let selectedCategoryIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case available
        case selected
        case selectedCategoryIds = "selected_category_ids"
    }
}

struct AgeSettings: Codable {
    let isUnder18: Bool?

    enum CodingKeys: String, CodingKey {
        case isUnder18 = "is_under_18"
    }
}

struct KidsModeSettings: Codable {
    let enabled: Bool?
}

struct SafetySettings: Codable {
    let filterInappropriateContent: Bool?
    let blockedKeywords: [String]?
    let blockedKeywordsText: String?

    enum CodingKeys: String, CodingKey {
        case filterInappropriateContent = "filter_inappropriate_content"
        case blockedKeywords = "blocked_keywords"
        case blockedKeywordsText = "blocked_keywords_text"
    }
}
