//
//  GameSettingRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for game settings. Mock-backed during the
//  current pre-integration phase.
//

import Foundation

protocol GameSettingRemoteDataSource {
    func fetchAchievements() async throws -> [GameAchievement]
}

// MARK: - Mock

struct MockGameSettingRemoteDataSource: GameSettingRemoteDataSource {

    func fetchAchievements() async throws -> [GameAchievement] {
        .mock
    }
}

private extension Array where Element == GameAchievement {

    static var mock: [GameAchievement] {
        let calendar = Calendar.current
        let now = Date()
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: now) ?? now
        }

        return [
            GameAchievement(
                details: "I won the match and racked up 27 kills",
                gameName: "PUBG Mobile",
                assetName: "game-pubg",
                date: daysAgo(1)
            ),
            GameAchievement(
                details: "I won the match against MO_Gamer 2–0",
                gameName: "FIFA 26",
                assetName: "game-fc26",
                date: daysAgo(1)
            ),
            GameAchievement(
                details: "Reached Diamond rank this season",
                gameName: "Call of Duty Mobile",
                date: daysAgo(3)
            ),
            GameAchievement(
                details: "Completed a 10-win streak",
                gameName: "Clash Royale",
                date: daysAgo(5)
            )
        ]
    }
}
