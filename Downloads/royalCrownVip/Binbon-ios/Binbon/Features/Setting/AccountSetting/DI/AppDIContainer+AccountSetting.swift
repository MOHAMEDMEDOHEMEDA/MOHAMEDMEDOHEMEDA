//
//  AppDIContainer+AccountSetting.swift
//  Binbon
//
//  Composition root — AccountSetting sub-feature factories.
//

import Foundation

extension AppDIContainer {

    func makeAccountSettingRepository() -> AccountSettingRepositoryProtocol {
        AccountSettingRepositoryImpl(settingRepo: makeSettingRepo())
    }

    func makeFetchProfileSettingUseCase() -> FetchProfileSettingUseCase {
        FetchProfileSettingUseCase(repository: makeAccountSettingRepository())
    }

    func makeSaveProfileSettingUseCase() -> SaveProfileSettingUseCase {
        SaveProfileSettingUseCase(repository: makeAccountSettingRepository())
    }

    func makeDeviceLogoutUseCase() -> DeviceLogoutUseCase {
        DeviceLogoutUseCase(repository: makeAccountSettingRepository())
    }

    func makeDeviceLogoutAllUseCase() -> DeviceLogoutAllUseCase {
        DeviceLogoutAllUseCase(repository: makeAccountSettingRepository())
    }

    func makeAddUserLinkUseCase() -> AddUserLinkUseCase {
        AddUserLinkUseCase(repository: makeAccountSettingRepository())
    }

    func makeDeleteUserLinkUseCase() -> DeleteUserLinkUseCase {
        DeleteUserLinkUseCase(repository: makeAccountSettingRepository())
    }

    func makeUploadAvatarUseCase() -> UploadAvatarUseCase {
        UploadAvatarUseCase(repository: makeAccountSettingRepository())
    }

    func makeDeleteAvatarUseCase() -> DeleteAvatarUseCase {
        DeleteAvatarUseCase(repository: makeAccountSettingRepository())
    }

    @MainActor
    func makeAccountSettingViewModel() -> AccountSettingViewModel {
        AccountSettingViewModel(
            fetchProfileSettingUseCase: makeFetchProfileSettingUseCase(),
            saveProfileSettingUseCase: makeSaveProfileSettingUseCase(),
            deviceLogoutUseCase: makeDeviceLogoutUseCase(),
            deviceLogoutAllUseCase: makeDeviceLogoutAllUseCase(),
            addUserLinkUseCase: makeAddUserLinkUseCase(),
            deleteUserLinkUseCase: makeDeleteUserLinkUseCase(),
            uploadAvatarUseCase: makeUploadAvatarUseCase(),
            deleteAvatarUseCase: makeDeleteAvatarUseCase()
        )
    }
}
