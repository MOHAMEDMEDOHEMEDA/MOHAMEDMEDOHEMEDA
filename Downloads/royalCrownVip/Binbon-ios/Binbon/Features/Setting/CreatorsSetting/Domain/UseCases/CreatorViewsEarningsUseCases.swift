//
//  CreatorViewsEarningsUseCases.swift
//  Binbon
//
//  Domain layer — one use case per creator views/earnings data operation.
//

import Foundation

struct FetchCreatorViewsEarningsStatsUseCase {
    private let repository: CreatorViewsEarningsRepositoryProtocol

    init(repository: CreatorViewsEarningsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [CreatorMetricStat] {
        try await repository.fetchStats()
    }
}

struct FetchCreatorViewsEarningsTrendUseCase {
    private let repository: CreatorViewsEarningsRepositoryProtocol

    init(repository: CreatorViewsEarningsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ChartPoint] {
        try await repository.fetchTrend()
    }
}
