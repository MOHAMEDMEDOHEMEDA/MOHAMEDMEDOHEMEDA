//
//  CreatorViewsEarningsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — creator views/earnings boundary the use cases depend on. Returns
//  reused presentation models as entities and throws `APIError`.
//

import Foundation

protocol CreatorViewsEarningsRepositoryProtocol {
    /// Views / ad-count / earnings metric cards.
    func fetchStats() async throws -> [CreatorMetricStat]

    /// Trend series backing the views/earnings line chart.
    func fetchTrend() async throws -> [ChartPoint]
}
