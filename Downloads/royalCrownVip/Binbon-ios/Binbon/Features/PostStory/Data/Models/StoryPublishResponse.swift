//
//  StoryPublishResponse.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import Foundation

struct StoryPublishResponse: Decodable, Equatable {
    let storyId: Int
    let publishedAt: String?

    enum CodingKeys: String, CodingKey {
        case storyId = "story_id"
        case publishedAt = "published_at"
    }
}
