//
//  CreatorStatisticsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — creator-statistics boundary the use cases depend on. Returns
//  reused presentation models as entities and throws `APIError`.
//

import Foundation

protocol CreatorStatisticsRepositoryProtocol {
    /// Overview metric cards.
    func fetchStats() async throws -> [StatisticsStat]

    /// Trend series backing the analytics line chart.
    func fetchTrend() async throws -> [ChartPoint]

    /// Videos listed under the content tab.
    func fetchContentVideos() async throws -> [ContentVideo]
}
