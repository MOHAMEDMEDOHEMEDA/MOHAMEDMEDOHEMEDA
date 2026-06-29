//
//  AppDIContainer+Stories.swift
//  Binbon
//
//  Composition root — Stories feature factories.
//

import Foundation

extension AppDIContainer {

    func makeStoriesRemoteDataSource() -> StoriesRemoteDataSource {
        MockStoriesRemoteDataSource()
    }

    func makeStoriesRepository() -> StoriesRepositoryProtocol {
        StoriesRepositoryImpl(remote: makeStoriesRemoteDataSource())
    }

    @MainActor
    func makeMyStoriesViewModel() -> MyStoriesViewModel {
        let repository = makeStoriesRepository()
        return MyStoriesViewModel(
            fetchProfileSummaryUseCase: FetchStoryProfileSummaryUseCase(repository: repository),
            fetchFriendsUseCase: FetchStoryFriendsUseCase(repository: repository),
            fetchStoriesUseCase: FetchStoriesUseCase(repository: repository),
            fetchTrendingUseCase: FetchTrendingStoriesUseCase(repository: repository),
            fetchSavedUseCase: FetchSavedStoriesUseCase(repository: repository),
            fetchSaveMyStoryDaysUseCase: FetchSaveMyStoryDaysUseCase(repository: repository)
        )
    }
}
