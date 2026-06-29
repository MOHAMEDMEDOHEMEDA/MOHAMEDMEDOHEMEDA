//
//  AppDIContainer+SecuritySetting.swift
//  Binbon
//
//  Composition root — SecuritySetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeSecuritySettingRepository() -> SecuritySettingRepositoryProtocol {
        SecuritySettingRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchSecuritySettingsUseCase() -> FetchSecuritySettingsUseCase {
        FetchSecuritySettingsUseCase(repository: makeSecuritySettingRepository())
    }

    func makeUpdateBiometricUseCase() -> UpdateBiometricUseCase {
        UpdateBiometricUseCase(repository: makeSecuritySettingRepository())
    }

    func makeDisable2FAUseCase() -> Disable2FAUseCase {
        Disable2FAUseCase(repository: makeSecuritySettingRepository())
    }

    func makeFetchSecurityActivityUseCase() -> FetchSecurityActivityUseCase {
        FetchSecurityActivityUseCase(repository: makeSecuritySettingRepository())
    }

    func makeFetchLoginHistoryUseCase() -> FetchLoginHistoryUseCase {
        FetchLoginHistoryUseCase(repository: makeSecuritySettingRepository())
    }

    @MainActor
    func makeSecuritySettingViewModel() -> SecuritySettingViewModel {
        SecuritySettingViewModel(
            fetchSecuritySettingsUseCase: makeFetchSecuritySettingsUseCase(),
            updateBiometricUseCase: makeUpdateBiometricUseCase(),
            disable2FAUseCase: makeDisable2FAUseCase(),
            fetchSecurityActivityUseCase: makeFetchSecurityActivityUseCase(),
            fetchLoginHistoryUseCase: makeFetchLoginHistoryUseCase()
        )
    }
}
