//
//  AppDIContainer+VoiceCall.swift
//  Binbon
//

import Foundation

extension AppDIContainer {

    func makeVoiceCallRemoteDataSource() -> VoiceCallRemoteDataSource {
        MockVoiceCallRemoteDataSource()
    }

    func makeVoiceCallRepository() -> VoiceCallRepositoryProtocol {
        VoiceCallRepositoryImpl(remote: makeVoiceCallRemoteDataSource())
    }

    func makeLoadVoiceCallSessionUseCase() -> LoadVoiceCallSessionUseCase {
        LoadVoiceCallSessionUseCase(repository: makeVoiceCallRepository())
    }

    @MainActor
    func makeVoiceCallViewModel() -> VoiceCallViewModel {
        VoiceCallViewModel(loadVoiceCallSessionUseCase: makeLoadVoiceCallSessionUseCase())
    }
}
