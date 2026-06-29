//
//  AppDIContainer+Income.swift
//  Binbon
//
//  Composition root — Income feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeIncomeRemoteDataSource() -> IncomeRemoteDataSource {
        MockIncomeRemoteDataSource()
    }

    func makeIncomeRepository() -> IncomeRepositoryProtocol {
        IncomeRepositoryImpl(remote: makeIncomeRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchIncomeBreakdownUseCase() -> FetchIncomeBreakdownUseCase {
        FetchIncomeBreakdownUseCase(repository: makeIncomeRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeIncomeViewModel() -> IncomeViewModel {
        IncomeViewModel(fetchBreakdownUseCase: makeFetchIncomeBreakdownUseCase())
    }
}
