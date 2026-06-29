//
//  AppDIContainer+CreatorViewsEarnings.swift
//  Binbon
//
//  Composition root — Creator Views/Earnings feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeCreatorViewsEarningsRemoteDataSource() -> CreatorViewsEarningsRemoteDataSource {
        MockCreatorViewsEarningsRemoteDataSource()
    }

    func makeCreatorViewsEarningsRepository() -> CreatorViewsEarningsRepositoryProtocol {
        CreatorViewsEarningsRepositoryImpl(remote: makeCreatorViewsEarningsRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchCreatorViewsEarningsStatsUseCase() -> FetchCreatorViewsEarningsStatsUseCase {
        FetchCreatorViewsEarningsStatsUseCase(repository: makeCreatorViewsEarningsRepository())
    }

    func makeFetchCreatorViewsEarningsTrendUseCase() -> FetchCreatorViewsEarningsTrendUseCase {
        FetchCreatorViewsEarningsTrendUseCase(repository: makeCreatorViewsEarningsRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeCreatorViewsEarningsViewModel() -> CreatorViewsEarningsViewModel {
        CreatorViewsEarningsViewModel(
            fetchStatsUseCase: makeFetchCreatorViewsEarningsStatsUseCase(),
            fetchTrendUseCase: makeFetchCreatorViewsEarningsTrendUseCase()
        )
    }
}
