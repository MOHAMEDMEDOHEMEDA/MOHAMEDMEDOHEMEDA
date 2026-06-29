//
//  GameSettingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — game-settings boundary the use cases depend on. Returns app
//  entities and throws `APIError`; the concrete implementation lives in Data.
//

import Foundation

protocol GameSettingRepositoryProtocol {
    /// The "Achievements & Points" feed entries.
    func fetchAchievements() async throws -> [GameAchievement]
}
