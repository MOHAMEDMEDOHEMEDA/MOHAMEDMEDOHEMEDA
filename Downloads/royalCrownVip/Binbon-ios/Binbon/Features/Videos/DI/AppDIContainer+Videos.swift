//
//  AppDIContainer+Videos.swift
//  Binbon
//
//  Composition root — Videos feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeVideosRemoteDataSource() -> VideosRemoteDataSource {
        MockVideosRemoteDataSource()
    }

    func makeVideosRepository() -> VideosRepositoryProtocol {
        VideosRepositoryImpl(remote: makeVideosRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchVideosFeedUseCase() -> FetchVideosFeedUseCase {
        FetchVideosFeedUseCase(repository: makeVideosRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeVideosViewModel() -> VideosViewModel {
        VideosViewModel(fetchVideosFeedUseCase: makeFetchVideosFeedUseCase())
    }
}
