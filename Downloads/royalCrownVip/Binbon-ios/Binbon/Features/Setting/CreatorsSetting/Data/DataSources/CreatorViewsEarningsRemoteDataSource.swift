//
//  CreatorViewsEarningsRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for creator views/earnings. Mock-backed during
//  the current pre-integration phase.
//

import Foundation

protocol CreatorViewsEarningsRemoteDataSource {
    func fetchStats() async throws -> [CreatorMetricStat]
    func fetchTrend() async throws -> [ChartPoint]
}

// MARK: - Mock

struct MockCreatorViewsEarningsRemoteDataSource: CreatorViewsEarningsRemoteDataSource {

    func fetchStats() async throws -> [CreatorMetricStat] {
        .mock
    }

    func fetchTrend() async throws -> [ChartPoint] {
        CreatorAnalyticsMock.wavyWeekTrend()
    }
}

private extension Array where Element == CreatorMetricStat {
    static let mock: [CreatorMetricStat] = [
        CreatorMetricStat(metric: .views,    value: 99_000, deltaValue: 50_000, changePercent: 98),
        CreatorMetricStat(metric: .adCount,  value: 99_000, deltaValue: 50_000, changePercent: 98),
        CreatorMetricStat(metric: .earnings, value: 99_000, deltaValue: 50_000, changePercent: 98)
    ]
}
