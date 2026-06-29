//
//  AppDIContainer+DataCacheSettings.swift
//  Binbon
//
//  Composition root — DataCacheSettings sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeDataCacheSettingsRepository() -> DataCacheSettingsRepositoryProtocol {
        DataCacheSettingsRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchDataStorageSettingsUseCase() -> FetchDataStorageSettingsUseCase {
        FetchDataStorageSettingsUseCase(repository: makeDataCacheSettingsRepository())
    }

    func makeUpdateDataStorageSettingsUseCase() -> UpdateDataStorageSettingsUseCase {
        UpdateDataStorageSettingsUseCase(repository: makeDataCacheSettingsRepository())
    }

    func makeClearCacheUseCase() -> ClearCacheUseCase {
        ClearCacheUseCase(repository: makeDataCacheSettingsRepository())
    }

    func makeDeleteMyAccountUseCase() -> DeleteMyAccountUseCase {
        DeleteMyAccountUseCase(repository: makeDataCacheSettingsRepository())
    }

    func makeExportPersonalDataUseCase() -> ExportPersonalDataUseCase {
        ExportPersonalDataUseCase(repository: makeDataCacheSettingsRepository())
    }

    @MainActor
    func makeDataCacheSettingsViewModel() -> DataCacheSettingsViewModel {
        DataCacheSettingsViewModel(
            fetchDataStorageSettingsUseCase: makeFetchDataStorageSettingsUseCase(),
            updateDataStorageSettingsUseCase: makeUpdateDataStorageSettingsUseCase(),
            clearCacheUseCase: makeClearCacheUseCase(),
            deleteMyAccountUseCase: makeDeleteMyAccountUseCase(),
            exportPersonalDataUseCase: makeExportPersonalDataUseCase()
        )
    }
}
