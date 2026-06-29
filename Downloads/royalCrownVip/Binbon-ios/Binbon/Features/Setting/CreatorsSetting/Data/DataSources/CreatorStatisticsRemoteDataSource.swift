//
//  CreatorStatisticsRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for creator statistics. Mock-backed during
//  the current pre-integration phase.
//

import Foundation

protocol CreatorStatisticsRemoteDataSource {
    func fetchStats() async throws -> [StatisticsStat]
    func fetchTrend() async throws -> [ChartPoint]
    func fetchContentVideos() async throws -> [ContentVideo]
}

// MARK: - Mock

struct MockCreatorStatisticsRemoteDataSource: CreatorStatisticsRemoteDataSource {

    func fetchStats() async throws -> [StatisticsStat] {
        .mock
    }

    func fetchTrend() async throws -> [ChartPoint] {
        CreatorAnalyticsMock.wavyWeekTrend()
    }

    func fetchContentVideos() async throws -> [ContentVideo] {
        .mock
    }
}

private extension Array where Element == StatisticsStat {
    static let mock: [StatisticsStat] = [
        StatisticsStat(metric: .views,     value: 99_000, deltaValue: 50_000, changePercent: 98),
        StatisticsStat(metric: .followers, value: 99_000, deltaValue: 50_000, changePercent: 98),
        StatisticsStat(metric: .likes,     value: 99_000, deltaValue: 50_000, changePercent: 98),
        StatisticsStat(metric: .comments,  value: 99_000, deltaValue: 50_000, changePercent: 98),
        StatisticsStat(metric: .shares,    value: 99_000, deltaValue: 50_000, changePercent: 98),
        StatisticsStat(metric: .earnings,  value: 99_000, deltaValue: 50_000, changePercent: 98)
    ]
}

private extension Array where Element == ContentVideo {
    static let mock: [ContentVideo] = {
        let sample = "فلوج في المنزل #بينبون #الشعب_الصيني_ماله_حل #البيت #فلوج"
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(year: 2025, month: 4, day: 22)) ?? Date()
        return (0..<8).map { _ in
            ContentVideo(thumbnailName: "artist_6", title: sample, viewsCount: 290_000, date: date)
        }
    }()
}
