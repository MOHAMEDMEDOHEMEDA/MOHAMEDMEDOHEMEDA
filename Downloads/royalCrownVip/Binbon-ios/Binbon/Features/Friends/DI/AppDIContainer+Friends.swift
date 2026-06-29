//
//  AppDIContainer+Friends.swift
//  Binbon
//
//  Composition root — Friends feature factories.
//

import Foundation

extension AppDIContainer {

    func makeFriendsTabRemoteDataSource() -> FriendsTabRemoteDataSource {
        MockFriendsTabRemoteDataSource()
    }

    func makeFriendsTabRepository() -> FriendsTabRepositoryProtocol {
        FriendsTabRepositoryImpl(remote: makeFriendsTabRemoteDataSource())
    }

    func makeLoadFriendsUseCase() -> LoadFriendsUseCase {
        LoadFriendsUseCase(repository: makeFriendsTabRepository())
    }

    @MainActor
    func makeFriendsTabViewModel() -> FriendsTabViewModel {
        FriendsTabViewModel(loadFriendsUseCase: makeLoadFriendsUseCase())
    }
}
