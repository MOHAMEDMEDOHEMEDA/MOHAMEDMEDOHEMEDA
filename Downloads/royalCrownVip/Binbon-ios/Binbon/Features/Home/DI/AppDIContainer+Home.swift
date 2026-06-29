//
//  AppDIContainer+Home.swift
//  Binbon
//
//  Composition root — Home feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeHomeRepository() -> HomeRepositoryProtocol {
        HomeRepositoryImpl(storage: storage)
    }

    // MARK: - Use cases

    func makeGetCurrentUserUseCase() -> GetCurrentUserUseCase {
        GetCurrentUserUseCase(repository: makeHomeRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(getCurrentUserUseCase: makeGetCurrentUserUseCase())
    }
}
