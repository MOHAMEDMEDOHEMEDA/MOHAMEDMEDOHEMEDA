//
//  AppDIContainer+InteractionSetting.swift
//  Binbon
//
//  Composition root — InteractionSetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeInteractionSettingRepository() -> InteractionSettingRepositoryProtocol {
        InteractionSettingRepositoryImpl(settingRepo: makeSettingRepo())
    }

    // MARK: - Use cases

    func makeFetchInteractionSettingsUseCase() -> FetchInteractionSettingsUseCase {
        FetchInteractionSettingsUseCase(repository: makeInteractionSettingRepository())
    }

    func makeUpdateInteractionSettingsUseCase() -> UpdateInteractionSettingsUseCase {
        UpdateInteractionSettingsUseCase(repository: makeInteractionSettingRepository())
    }

    func makeFetchBlockedUsersUseCase() -> FetchBlockedUsersUseCase {
        FetchBlockedUsersUseCase(repository: makeInteractionSettingRepository())
    }

    func makeBlockUserUseCase() -> BlockUserUseCase {
        BlockUserUseCase(repository: makeInteractionSettingRepository())
    }

    func makeUnblockUserUseCase() -> UnblockUserUseCase {
        UnblockUserUseCase(repository: makeInteractionSettingRepository())
    }

    func makeFetchInteractionLiveStreamSettingsUseCase() -> FetchInteractionLiveStreamSettingsUseCase {
        FetchInteractionLiveStreamSettingsUseCase(repository: makeInteractionSettingRepository())
    }

    func makeUpdateInteractionLiveStreamSettingsUseCase() -> UpdateInteractionLiveStreamSettingsUseCase {
        UpdateInteractionLiveStreamSettingsUseCase(repository: makeInteractionSettingRepository())
    }

    // MARK: - View models

    @MainActor
    func makeInteractionSettingViewModel() -> InteractionSettingViewModel {
        InteractionSettingViewModel(
            fetchInteractionSettingsUseCase: makeFetchInteractionSettingsUseCase(),
            updateInteractionSettingsUseCase: makeUpdateInteractionSettingsUseCase()
        )
    }

    @MainActor
    func makeBlockedUsersViewModel() -> BlockedUsersViewModel {
        BlockedUsersViewModel(
            fetchBlockedUsersUseCase: makeFetchBlockedUsersUseCase(),
            blockUserUseCase: makeBlockUserUseCase(),
            unblockUserUseCase: makeUnblockUserUseCase()
        )
    }

    @MainActor
    func makeLiveStreamSettingsViewModel() -> LiveStreamSettingsViewModel {
        LiveStreamSettingsViewModel(
            fetchLiveStreamSettingsUseCase: makeFetchInteractionLiveStreamSettingsUseCase(),
            updateLiveStreamSettingsUseCase: makeUpdateInteractionLiveStreamSettingsUseCase()
        )
    }
}
