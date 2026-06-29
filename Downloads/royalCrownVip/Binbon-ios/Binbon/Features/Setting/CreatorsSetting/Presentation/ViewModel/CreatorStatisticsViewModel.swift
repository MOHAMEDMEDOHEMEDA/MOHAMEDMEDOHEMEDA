//
//  CreatorStatisticsViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import Foundation
import Combine

@MainActor
final class CreatorStatisticsViewModel: ObservableObject {

    @Published var selectedTab: StatisticsTab = .overview
    @Published var selectedPeriod: CreatorViewsPeriod = .weekly
    @Published var selectedMetric: StatisticsMetric = .views

    @Published var stats: [StatisticsStat] = []
    @Published var chartPoints: [ChartPoint] = []

    // MARK: - Content tab
    @Published var selectedContentMetric: StatisticsMetric = .views

    let contentMetricOptions: [StatisticsMetric] = [.views, .likes, .shares, .comments]

    @Published var contentVideos: [ContentVideo] = []

    @Published var isLoading = false
    @Published var error: APIError?

    // MARK: - Use cases
    private let fetchStatsUseCase: FetchCreatorStatsUseCase
    private let fetchTrendUseCase: FetchCreatorStatisticsTrendUseCase
    private let fetchContentVideosUseCase: FetchCreatorContentVideosUseCase

    init(
        fetchStatsUseCase: FetchCreatorStatsUseCase,
        fetchTrendUseCase: FetchCreatorStatisticsTrendUseCase,
        fetchContentVideosUseCase: FetchCreatorContentVideosUseCase
    ) {
        self.fetchStatsUseCase = fetchStatsUseCase
        self.fetchTrendUseCase = fetchTrendUseCase
        self.fetchContentVideosUseCase = fetchContentVideosUseCase
        load()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchStatsUseCase: container.makeFetchCreatorStatsUseCase(),
            fetchTrendUseCase: container.makeFetchCreatorStatisticsTrendUseCase(),
            fetchContentVideosUseCase: container.makeFetchCreatorContentVideosUseCase()
        )
    }

    func load() {
        Task {
            isLoading = true
            error = nil
            do {
                stats = try await fetchStatsUseCase.execute()
                chartPoints = try await fetchTrendUseCase.execute()
                contentVideos = try await fetchContentVideosUseCase.execute()
                isLoading = false
            } catch {
                isLoading = false
                self.error = asAPIError(error)
            }
        }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
