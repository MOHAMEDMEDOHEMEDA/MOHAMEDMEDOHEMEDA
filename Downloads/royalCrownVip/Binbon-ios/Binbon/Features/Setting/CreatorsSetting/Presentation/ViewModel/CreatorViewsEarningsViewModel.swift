//
//  CreatorViewsEarningsViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import Foundation
import Combine

@MainActor
final class CreatorViewsEarningsViewModel: ObservableObject {

    @Published var selectedPeriod: CreatorViewsPeriod = .weekly
    @Published var selectedMetric: CreatorViewsMetric = .views

    @Published var stats: [CreatorMetricStat] = []
    @Published var chartPoints: [ChartPoint] = []

    @Published var isLoading = false
    @Published var error: APIError?

    // MARK: - Use cases
    private let fetchStatsUseCase: FetchCreatorViewsEarningsStatsUseCase
    private let fetchTrendUseCase: FetchCreatorViewsEarningsTrendUseCase

    init(
        fetchStatsUseCase: FetchCreatorViewsEarningsStatsUseCase,
        fetchTrendUseCase: FetchCreatorViewsEarningsTrendUseCase
    ) {
        self.fetchStatsUseCase = fetchStatsUseCase
        self.fetchTrendUseCase = fetchTrendUseCase
        load()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchStatsUseCase: container.makeFetchCreatorViewsEarningsStatsUseCase(),
            fetchTrendUseCase: container.makeFetchCreatorViewsEarningsTrendUseCase()
        )
    }

    func load() {
        Task {
            isLoading = true
            error = nil
            do {
                stats = try await fetchStatsUseCase.execute()
                chartPoints = try await fetchTrendUseCase.execute()
                isLoading = false
            } catch {
                isLoading = false
                self.error = asAPIError(error)
            }
        }
    }

    func stat(for metric: CreatorViewsMetric) -> CreatorMetricStat? {
        stats.first { $0.metric == metric }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
