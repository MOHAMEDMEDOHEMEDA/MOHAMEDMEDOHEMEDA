//
//  AppDIContainer+VideoCall.swift
//  Binbon
//

import Foundation

extension AppDIContainer {

    func makeVideoCallRemoteDataSource() -> VideoCallRemoteDataSource {
        MockVideoCallRemoteDataSource()
    }

    func makeVideoCallRepository() -> VideoCallRepositoryProtocol {
        VideoCallRepositoryImpl(remote: makeVideoCallRemoteDataSource())
    }

    func makeLoadVideoCallSessionUseCase() -> LoadVideoCallSessionUseCase {
        LoadVideoCallSessionUseCase(repository: makeVideoCallRepository())
    }

    @MainActor
    func makeVideoCallViewModel() -> VideoCallViewModel {
        VideoCallViewModel(loadVideoCallSessionUseCase: makeLoadVideoCallSessionUseCase())
    }
}
