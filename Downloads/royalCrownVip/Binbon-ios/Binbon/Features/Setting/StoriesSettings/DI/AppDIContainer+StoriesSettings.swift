//
//  AppDIContainer+StoriesSettings.swift
//  Binbon
//
//  Composition root — StoriesSettings sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeStoriesSettingsRepository() -> StoriesSettingsRepositoryProtocol {
        StoriesSettingsRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchStorySettingsUseCase() -> FetchStorySettingsUseCase {
        FetchStorySettingsUseCase(repository: makeStoriesSettingsRepository())
    }

    func makeUpdateStorySettingsUseCase() -> UpdateStorySettingsUseCase {
        UpdateStorySettingsUseCase(repository: makeStoriesSettingsRepository())
    }

    @MainActor
    func makeStoriesSettingsViewModel() -> StoriesSettingsViewModel {
        StoriesSettingsViewModel(
            fetchStorySettingsUseCase: makeFetchStorySettingsUseCase(),
            updateStorySettingsUseCase: makeUpdateStorySettingsUseCase()
        )
    }
}
