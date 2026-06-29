//
//  AppDIContainer+Shorts.swift
//  Binbon
//
//  Composition root — Shorts feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeShortsRemoteDataSource() -> ShortsRemoteDataSource {
        MockShortsRemoteDataSource()
    }

    func makeShortsRepository() -> ShortsRepositoryProtocol {
        ShortsRepositoryImpl(remote: makeShortsRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchShortsUseCase() -> FetchShortsUseCase {
        FetchShortsUseCase(repository: makeShortsRepository())
    }

    func makeToggleShortLikeUseCase() -> ToggleShortLikeUseCase {
        ToggleShortLikeUseCase(repository: makeShortsRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeShortsViewModel() -> ShortsViewModel {
        ShortsViewModel(
            fetchShortsUseCase: makeFetchShortsUseCase(),
            toggleLikeUseCase: makeToggleShortLikeUseCase()
        )
    }
}
