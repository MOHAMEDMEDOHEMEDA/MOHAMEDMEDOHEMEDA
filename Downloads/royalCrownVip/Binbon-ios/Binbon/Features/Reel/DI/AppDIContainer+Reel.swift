//
//  AppDIContainer+Reel.swift
//  Binbon
//
//  Composition root — Reel feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeReelsRemoteDataSource() -> ReelsRemoteDataSource {
        MockReelsRemoteDataSource()
    }

    func makeReelsRepository() -> ReelsRepositoryProtocol {
        ReelsRepositoryImpl(remote: makeReelsRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchReelsUseCase() -> FetchReelsUseCase {
        FetchReelsUseCase(repository: makeReelsRepository())
    }

    func makeToggleReelLikeUseCase() -> ToggleReelLikeUseCase {
        ToggleReelLikeUseCase(repository: makeReelsRepository())
    }

    func makeToggleReelBookmarkUseCase() -> ToggleReelBookmarkUseCase {
        ToggleReelBookmarkUseCase(repository: makeReelsRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeReelsViewModel() -> ReelsViewModel {
        ReelsViewModel(
            fetchReelsUseCase: makeFetchReelsUseCase(),
            toggleLikeUseCase: makeToggleReelLikeUseCase(),
            toggleBookmarkUseCase: makeToggleReelBookmarkUseCase()
        )
    }
}
