//
//  AppDIContainer+ContentPrivacySetting.swift
//  Binbon
//
//  Composition root — ContentPrivacySetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeContentPrivacySettingRepository() -> ContentPrivacySettingRepositoryProtocol {
        ContentPrivacySettingRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchContentControlSettingsUseCase() -> FetchContentControlSettingsUseCase {
        FetchContentControlSettingsUseCase(repository: makeContentPrivacySettingRepository())
    }

    func makeUpdateContentControlSettingsUseCase() -> UpdateContentControlSettingsUseCase {
        UpdateContentControlSettingsUseCase(repository: makeContentPrivacySettingRepository())
    }

    @MainActor
    func makeContentPrivacySettingViewModel() -> ContentPrivacySettingViewModel {
        ContentPrivacySettingViewModel(
            fetchContentControlSettingsUseCase: makeFetchContentControlSettingsUseCase(),
            updateContentControlSettingsUseCase: makeUpdateContentControlSettingsUseCase()
        )
    }
}
