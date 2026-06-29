//
//  AppDIContainer+LegalSettings.swift
//  Binbon
//
//  Composition root — LegalSettings sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeLegalSettingsRepository() -> LegalSettingsRepositoryProtocol {
        LegalSettingsRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchLegalSettingsUseCase() -> FetchLegalSettingsUseCase {
        FetchLegalSettingsUseCase(repository: makeLegalSettingsRepository())
    }

    @MainActor
    func makeLegalSettingsViewModel() -> LegalSettingsViewModel {
        LegalSettingsViewModel(fetchLegalSettingsUseCase: makeFetchLegalSettingsUseCase())
    }
}
