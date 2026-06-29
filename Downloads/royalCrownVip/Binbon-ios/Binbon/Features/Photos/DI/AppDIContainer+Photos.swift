//
//  AppDIContainer+Photos.swift
//  Binbon
//
//  Composition root — Photos feature factories.
//

import Foundation

extension AppDIContainer {

    func makePhotosRemoteDataSource() -> PhotosRemoteDataSource {
        MockPhotosRemoteDataSource()
    }

    func makePhotosRepository() -> PhotosRepositoryProtocol {
        PhotosRepositoryImpl(remote: makePhotosRemoteDataSource())
    }

    func makeFetchPhotosFeedUseCase() -> FetchPhotosFeedUseCase {
        FetchPhotosFeedUseCase(repository: makePhotosRepository())
    }

    @MainActor
    func makePhotosViewModel() -> PhotosViewModel {
        PhotosViewModel(fetchFeedUseCase: makeFetchPhotosFeedUseCase())
    }
}
