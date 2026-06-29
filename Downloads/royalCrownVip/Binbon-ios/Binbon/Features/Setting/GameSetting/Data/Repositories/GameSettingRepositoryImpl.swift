//
//  GameSettingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `GameSettingRepositoryProtocol`, driving the remote
//  data source.
//

import Foundation

final class GameSettingRepositoryImpl: GameSettingRepositoryProtocol {

    private let remote: GameSettingRemoteDataSource

    init(remote: GameSettingRemoteDataSource) {
        self.remote = remote
    }

    func fetchAchievements() async throws -> [GameAchievement] {
        try await remote.fetchAchievements()
    }
}
