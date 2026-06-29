//
//  CreatorStatisticsUseCases.swift
//  Binbon
//
//  Domain layer — one use case per creator-statistics data operation.
//

import Foundation

struct FetchCreatorStatsUseCase {
    private let repository: CreatorStatisticsRepositoryProtocol

    init(repository: CreatorStatisticsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [StatisticsStat] {
        try await repository.fetchStats()
    }
}

struct FetchCreatorStatisticsTrendUseCase {
    private let repository: CreatorStatisticsRepositoryProtocol

    init(repository: CreatorStatisticsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ChartPoint] {
        try await repository.fetchTrend()
    }
}

struct FetchCreatorContentVideosUseCase {
    private let repository: CreatorStatisticsRepositoryProtocol

    init(repository: CreatorStatisticsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ContentVideo] {
        try await repository.fetchContentVideos()
    }
}
