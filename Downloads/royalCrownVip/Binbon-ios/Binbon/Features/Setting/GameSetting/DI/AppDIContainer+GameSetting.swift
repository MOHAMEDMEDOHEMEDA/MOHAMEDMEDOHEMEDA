//
//  AppDIContainer+GameSetting.swift
//  Binbon
//
//  Composition root — GameSetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeGameSettingRemoteDataSource() -> GameSettingRemoteDataSource {
        MockGameSettingRemoteDataSource()
    }

    func makeGameSettingRepository() -> GameSettingRepositoryProtocol {
        GameSettingRepositoryImpl(remote: makeGameSettingRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchGameAchievementsUseCase() -> FetchGameAchievementsUseCase {
        FetchGameAchievementsUseCase(repository: makeGameSettingRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeGameSettingViewModel() -> GameSettingViewModel {
        GameSettingViewModel(fetchAchievementsUseCase: makeFetchGameAchievementsUseCase())
    }
}
