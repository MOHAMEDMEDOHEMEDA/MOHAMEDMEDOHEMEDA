//
//  FetchGameAchievementsUseCase.swift
//  Binbon
//
//  Domain layer — loads the game achievements feed.
//

import Foundation

struct FetchGameAchievementsUseCase {
    private let repository: GameSettingRepositoryProtocol

    init(repository: GameSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [GameAchievement] {
        try await repository.fetchAchievements()
    }
}
