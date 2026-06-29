//
//  CreatorStatisticsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `CreatorStatisticsRepositoryProtocol`, driving the remote
//  data source.
//

import Foundation

final class CreatorStatisticsRepositoryImpl: CreatorStatisticsRepositoryProtocol {

    private let remote: CreatorStatisticsRemoteDataSource

    init(remote: CreatorStatisticsRemoteDataSource) {
        self.remote = remote
    }

    func fetchStats() async throws -> [StatisticsStat] {
        try await remote.fetchStats()
    }

    func fetchTrend() async throws -> [ChartPoint] {
        try await remote.fetchTrend()
    }

    func fetchContentVideos() async throws -> [ContentVideo] {
        try await remote.fetchContentVideos()
    }
}
