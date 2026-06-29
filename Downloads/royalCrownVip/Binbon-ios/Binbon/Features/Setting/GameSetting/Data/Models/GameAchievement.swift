//
//  GameAchievement.swift
//  Binbon
//
//  A single entry in the "Achievements & Points" feed (one match / milestone).
//

import Foundation

struct GameAchievement: Identifiable, Hashable {
    let id: UUID
    /// What the player did, e.g. "I won the match and racked up 27 kills".
    let details: String
    /// The game the achievement belongs to, e.g. "PUBG Mobile".
    let gameName: String
    /// Local asset-catalog image name for the game cover (takes priority).
    let assetName: String?
    /// Remote cover/thumbnail for the game (used when no local asset).
    let thumbnailURL: String?
    /// When it happened — drives the date header and the period filter.
    let date: Date

    init(id: UUID = UUID(),
         details: String,
         gameName: String,
         assetName: String? = nil,
         thumbnailURL: String? = nil,
         date: Date) {
        self.id = id
        self.details = details
        self.gameName = gameName
        self.assetName = assetName
        self.thumbnailURL = thumbnailURL
        self.date = date
    }
}
