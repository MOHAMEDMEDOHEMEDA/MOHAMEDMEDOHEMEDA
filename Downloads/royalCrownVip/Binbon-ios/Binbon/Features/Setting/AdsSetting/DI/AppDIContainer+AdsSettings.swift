//
//  AppDIContainer+AdsSettings.swift
//  Binbon
//
//  Composition root — AdsSetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeAdsSettingsRepository() -> AdsSettingsRepositoryProtocol {
        AdsSettingsRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchAdsSettingsUseCase() -> FetchAdsSettingsUseCase {
        FetchAdsSettingsUseCase(repository: makeAdsSettingsRepository())
    }

    func makeUpdateAdsSettingsUseCase() -> UpdateAdsSettingsUseCase {
        UpdateAdsSettingsUseCase(repository: makeAdsSettingsRepository())
    }

    @MainActor
    func makeAdsSettingViewModel() -> AdsSettingViewModel {
        AdsSettingViewModel(
            fetchAdsSettingsUseCase: makeFetchAdsSettingsUseCase(),
            updateAdsSettingsUseCase: makeUpdateAdsSettingsUseCase()
        )
    }
}
