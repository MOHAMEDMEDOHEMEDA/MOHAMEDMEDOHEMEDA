//
//  AppDIContainer+CreatorStatistics.swift
//  Binbon
//
//  Composition root — Creator Statistics feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeCreatorStatisticsRemoteDataSource() -> CreatorStatisticsRemoteDataSource {
        MockCreatorStatisticsRemoteDataSource()
    }

    func makeCreatorStatisticsRepository() -> CreatorStatisticsRepositoryProtocol {
        CreatorStatisticsRepositoryImpl(remote: makeCreatorStatisticsRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchCreatorStatsUseCase() -> FetchCreatorStatsUseCase {
        FetchCreatorStatsUseCase(repository: makeCreatorStatisticsRepository())
    }

    func makeFetchCreatorStatisticsTrendUseCase() -> FetchCreatorStatisticsTrendUseCase {
        FetchCreatorStatisticsTrendUseCase(repository: makeCreatorStatisticsRepository())
    }

    func makeFetchCreatorContentVideosUseCase() -> FetchCreatorContentVideosUseCase {
        FetchCreatorContentVideosUseCase(repository: makeCreatorStatisticsRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeCreatorStatisticsViewModel() -> CreatorStatisticsViewModel {
        CreatorStatisticsViewModel(
            fetchStatsUseCase: makeFetchCreatorStatsUseCase(),
            fetchTrendUseCase: makeFetchCreatorStatisticsTrendUseCase(),
            fetchContentVideosUseCase: makeFetchCreatorContentVideosUseCase()
        )
    }
}
