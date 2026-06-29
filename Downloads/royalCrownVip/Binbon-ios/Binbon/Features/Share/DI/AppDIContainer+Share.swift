//
//  AppDIContainer+Share.swift
//  Binbon
//
//  Composition root — Share feature factories.
//

import Foundation

extension AppDIContainer {

    func makeShareRemoteDataSource() -> ShareRemoteDataSource {
        MockShareRemoteDataSource()
    }

    func makeShareRepository() -> ShareRepositoryProtocol {
        ShareRepositoryImpl(remote: makeShareRemoteDataSource())
    }

    func makeFetchShareContactsUseCase() -> FetchShareContactsUseCase {
        FetchShareContactsUseCase(repository: makeShareRepository())
    }

    @MainActor
    func makeShareViewModel() -> ShareViewModel {
        ShareViewModel(fetchContactsUseCase: makeFetchShareContactsUseCase())
    }
}
