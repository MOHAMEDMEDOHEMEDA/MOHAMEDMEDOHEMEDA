//
//  AppDIContainer+Posts.swift
//  Binbon
//
//  Composition root — Posts feature factories.
//

import Foundation

extension AppDIContainer {

    func makePostsRemoteDataSource() -> PostsRemoteDataSource {
        MockPostsRemoteDataSource()
    }

    func makePostsRepository() -> PostsRepositoryProtocol {
        PostsRepositoryImpl(remote: makePostsRemoteDataSource())
    }

    func makeLoadPostsFeedUseCase() -> LoadPostsFeedUseCase {
        LoadPostsFeedUseCase(repository: makePostsRepository())
    }

    @MainActor
    func makePostsViewModel() -> PostsViewModel {
        PostsViewModel(loadFeedUseCase: makeLoadPostsFeedUseCase())
    }
}
