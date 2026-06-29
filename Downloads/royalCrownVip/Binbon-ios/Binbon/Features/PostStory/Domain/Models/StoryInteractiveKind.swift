//
//  StoryInteractiveKind.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import Foundation

enum StoryInteractiveKind: String, Codable, CaseIterable {
    case text
    case mention
    case hashtag
    case poll
    case addYours
    case location
    case liveEvent
    case emoji
    case gif
    case gloryAsset
}
