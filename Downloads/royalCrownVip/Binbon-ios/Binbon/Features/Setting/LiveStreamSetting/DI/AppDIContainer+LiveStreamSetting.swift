//
//  AppDIContainer+LiveStreamSetting.swift
//  Binbon
//
//  Composition root — LiveStreamSetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeLiveStreamSettingRepository() -> LiveStreamSettingRepositoryProtocol {
        LiveStreamSettingRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchLiveStreamSettingsUseCase() -> FetchLiveStreamSettingsUseCase {
        FetchLiveStreamSettingsUseCase(repository: makeLiveStreamSettingRepository())
    }

    func makeUpdateLiveStreamSettingsUseCase() -> UpdateLiveStreamSettingsUseCase {
        UpdateLiveStreamSettingsUseCase(repository: makeLiveStreamSettingRepository())
    }

    func makeFetchLiveSchedulesUseCase() -> FetchLiveSchedulesUseCase {
        FetchLiveSchedulesUseCase(repository: makeLiveStreamSettingRepository())
    }

    func makeCreateLiveScheduleUseCase() -> CreateLiveScheduleUseCase {
        CreateLiveScheduleUseCase(repository: makeLiveStreamSettingRepository())
    }

    func makeDeleteLiveScheduleUseCase() -> DeleteLiveScheduleUseCase {
        DeleteLiveScheduleUseCase(repository: makeLiveStreamSettingRepository())
    }

    @MainActor
    func makeLiveStreamSettingViewModel() -> LiveStreamSettingViewModel {
        LiveStreamSettingViewModel(
            fetchLiveStreamSettingsUseCase: makeFetchLiveStreamSettingsUseCase(),
            updateLiveStreamSettingsUseCase: makeUpdateLiveStreamSettingsUseCase(),
            fetchLiveSchedulesUseCase: makeFetchLiveSchedulesUseCase(),
            createLiveScheduleUseCase: makeCreateLiveScheduleUseCase(),
            deleteLiveScheduleUseCase: makeDeleteLiveScheduleUseCase()
        )
    }
}
