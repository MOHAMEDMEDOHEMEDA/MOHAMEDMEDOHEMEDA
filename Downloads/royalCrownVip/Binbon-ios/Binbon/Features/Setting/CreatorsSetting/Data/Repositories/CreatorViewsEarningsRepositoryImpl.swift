//
//  CreatorViewsEarningsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `CreatorViewsEarningsRepositoryProtocol`, driving the
//  remote data source.
//

import Foundation

final class CreatorViewsEarningsRepositoryImpl: CreatorViewsEarningsRepositoryProtocol {

    private let remote: CreatorViewsEarningsRemoteDataSource

    init(remote: CreatorViewsEarningsRemoteDataSource) {
        self.remote = remote
    }

    func fetchStats() async throws -> [CreatorMetricStat] {
        try await remote.fetchStats()
    }

    func fetchTrend() async throws -> [ChartPoint] {
        try await remote.fetchTrend()
    }
}
