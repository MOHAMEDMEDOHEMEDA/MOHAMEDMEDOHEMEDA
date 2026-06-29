//
//  AppDIContainer+GoldRecharge.swift
//  Binbon
//
//  Composition root — GoldRecharge feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeGoldRechargeRemoteDataSource() -> GoldRechargeRemoteDataSource {
        MockGoldRechargeRemoteDataSource()
    }

    func makeGoldRechargeRepository() -> GoldRechargeRepositoryProtocol {
        GoldRechargeRepositoryImpl(remote: makeGoldRechargeRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchGoldPackagesUseCase() -> FetchGoldPackagesUseCase {
        FetchGoldPackagesUseCase(repository: makeGoldRechargeRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeGoldRechargeViewModel() -> GoldRechargeViewModel {
        GoldRechargeViewModel(fetchPackagesUseCase: makeFetchGoldPackagesUseCase())
    }
}
