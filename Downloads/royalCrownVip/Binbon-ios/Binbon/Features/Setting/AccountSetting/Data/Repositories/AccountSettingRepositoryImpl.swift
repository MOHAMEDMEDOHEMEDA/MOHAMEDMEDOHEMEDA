//
//  AccountSettingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `AccountSettingRepositoryProtocol`. Wraps the shared
//  `SettingRepo`, unwrapping the transport envelope so the domain only sees the
//  account entities. A `status == false` envelope (or missing payload) is surfaced
//  as a thrown `APIError` carrying the server message.
//

import UIKit

final class AccountSettingRepositoryImpl: AccountSettingRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchProfileSetting() async throws -> AccountSettingResponse {
        switch await settingRepo.fetchProfileSetting() {
        case .success(let response):
            return try unwrap(response)
        case .failure(let error):
            throw error
        }
    }

    func patchProfileSetting(request: SaveAccountRequest) async throws -> AccountSettingResponse {
        switch await settingRepo.patchProfileSetting(request: request) {
        case .success(let response):
            return try unwrap(response, failureMessage: "profile_settings_update_failed".localized)
        case .failure(let error):
            throw error
        }
    }

    func deviceLogout(id: Int) async throws -> AccountSettingResponse {
        switch await settingRepo.deviceLogout(id: id) {
        case .success(let response):
            return try unwrap(response, failureMessage: "device_logout_failed".localized)
        case .failure(let error):
            throw error
        }
    }

    func deviceLogoutAll() async throws -> AccountSettingResponse {
        switch await settingRepo.deviceLogoutAll() {
        case .success(let response):
            return try unwrap(response, failureMessage: "other_devices_logout_failed".localized)
        case .failure(let error):
            throw error
        }
    }

    func addUserLink(request: AccountLinkRequest) async throws -> [AccountLinkRequest] {
        switch await settingRepo.addUserLink(request: request) {
        case .success(let response):
            return try unwrap(response, failureMessage: "link_url_failed".localized)
        case .failure(let error):
            throw error
        }
    }

    func deleteUserLink(id: Int) async throws {
        switch await settingRepo.deleteUserLink(id: id) {
        case .success(let response):
            guard response.status == true else {
                throw APIError(type: .unknown, message: response.message)
            }
        case .failure(let error):
            throw error
        }
    }

    func uploadAvatar(image: UIImage) async throws -> UploadedAvatarResponse {
        switch await settingRepo.uploadAvatar(image: image) {
        case .success(let response):
            return try unwrap(response, failureMessage: "profile_photo_upload_failed".localized)
        case .failure(let error):
            throw error
        }
    }

    func deleteAvatar(id: Int) async throws -> DeleteAvatarResponse {
        switch await settingRepo.deleteAvatar(id: id) {
        case .success(let response):
            return try unwrap(response, failureMessage: "profile_photo_delete_failed".localized)
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Helpers

    /// Unwraps a `BaseResponse`, throwing when the server reports failure or omits the payload.
    private func unwrap<T>(_ response: BaseResponse<T>, failureMessage: String? = nil) throws -> T {
        if response.status == false {
            throw APIError(type: .unknown, message: response.message ?? failureMessage)
        }
        guard let data = response.data else {
            throw APIError(type: .parsing, message: response.message ?? failureMessage)
        }
        return data
    }
}
