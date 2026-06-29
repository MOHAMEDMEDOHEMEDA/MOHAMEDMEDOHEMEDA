//
//  AppDIContainer+Comments.swift
//  Binbon
//
//  Composition root — Comments feature factories.
//

import Foundation

extension AppDIContainer {

    func makeCommentsRemoteDataSource() -> CommentsRemoteDataSource {
        MockCommentsRemoteDataSource()
    }

    func makeCommentsRepository() -> CommentsRepositoryProtocol {
        CommentsRepositoryImpl(remote: makeCommentsRemoteDataSource())
    }

    func makeFetchCommentsUseCase() -> FetchCommentsUseCase {
        FetchCommentsUseCase(repository: makeCommentsRepository())
    }

    @MainActor
    func makeCommentsViewModel(targetID: String, initialCount: Int = 0) -> CommentsViewModel {
        CommentsViewModel(
            targetID: targetID,
            initialCount: initialCount,
            fetchCommentsUseCase: makeFetchCommentsUseCase()
        )
    }
}
