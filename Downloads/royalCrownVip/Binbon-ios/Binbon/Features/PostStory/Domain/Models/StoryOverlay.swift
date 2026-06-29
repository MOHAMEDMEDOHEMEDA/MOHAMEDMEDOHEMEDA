//
//  StoryOverlay.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import Foundation
import SwiftUI

struct StoryTextPayload: Codable, Equatable {
    var text: String
    var fontName: String
    var fontSize: CGFloat
    var colorHex: String
    var hasBackground: Bool
    var backgroundHex: String?
}

struct StoryPollPayload: Codable, Equatable {
    var question: String
    var options: [String]
    var percents: [Int]
    var showResults: Bool
}

struct StoryAddYoursPayload: Codable, Equatable {
    var prompt: String
    var emoji: String
    var sliderPercent: CGFloat
}

struct StoryLiveEventPayload: Codable, Equatable {
    var title: String
    var date: Date?
    var duration: TimeInterval?
}

struct StoryGifPayload: Codable, Equatable {
    var previewURL: String
    var fullURL: String
    var previewAsset: String?
}

enum StoryOverlayKind: Codable, Equatable {
    case text(StoryTextPayload)
    case mention(username: String)
    case hashtag(tag: String)
    case poll(StoryPollPayload)
    case addYours(StoryAddYoursPayload)
    case location(name: String)
    case liveEvent(StoryLiveEventPayload)
    case emoji(String)
    case gif(StoryGifPayload)
    case image(assetName: String)
}

struct StoryOverlay: Identifiable, Equatable {
    let id: UUID
    var kind: StoryOverlayKind
    var position: CGPoint
    var scale: CGFloat
    var rotation: Angle
    var duration: TimeInterval?

    init(
        id: UUID = UUID(),
        kind: StoryOverlayKind,
        position: CGPoint = .zero,
        scale: CGFloat = 1,
        rotation: Angle = .zero,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.kind = kind
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.duration = duration
    }
}
