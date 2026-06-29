//
//  AppDIContainer+Activity.swift
//  Binbon
//
//  Composition root — HomeNotifications (Activity) feature factories.
//

import Foundation

extension AppDIContainer {

    func makeActivityRemoteDataSource() -> ActivityRemoteDataSource {
        MockActivityRemoteDataSource()
    }

    func makeActivityRepository() -> ActivityRepositoryProtocol {
        ActivityRepositoryImpl(remote: makeActivityRemoteDataSource())
    }

    func makeFetchActivityUseCase() -> FetchActivityUseCase {
        FetchActivityUseCase(repository: makeActivityRepository())
    }

    func makeFollowFromActivityUseCase() -> FollowFromActivityUseCase {
        FollowFromActivityUseCase(repository: makeActivityRepository())
    }

    @MainActor
    func makeActivityViewModel() -> ActivityViewModel {
        let repository = makeActivityRepository()
        return ActivityViewModel(
            fetchActivityUseCase: FetchActivityUseCase(repository: repository),
            followUseCase: FollowFromActivityUseCase(repository: repository)
        )
    }
}
