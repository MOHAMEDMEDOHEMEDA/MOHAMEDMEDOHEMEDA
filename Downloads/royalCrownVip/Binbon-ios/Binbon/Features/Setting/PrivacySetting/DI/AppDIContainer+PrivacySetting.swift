//
//  AppDIContainer+PrivacySetting.swift
//  Binbon
//
//  Composition root — PrivacySetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makePrivacySettingRepository() -> PrivacySettingRepositoryProtocol {
        PrivacySettingRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchPrivacySettingUseCase() -> FetchPrivacySettingUseCase {
        FetchPrivacySettingUseCase(repository: makePrivacySettingRepository())
    }

    func makeUpdatePrivacySettingUseCase() -> UpdatePrivacySettingUseCase {
        UpdatePrivacySettingUseCase(repository: makePrivacySettingRepository())
    }

    @MainActor
    func makePrivacySettingViewModel() -> PrivacySettingViewModel {
        PrivacySettingViewModel(
            fetchPrivacySettingUseCase: makeFetchPrivacySettingUseCase(),
            updatePrivacySettingUseCase: makeUpdatePrivacySettingUseCase()
        )
    }
}
