//
//  AccountSettingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — account settings boundary the use cases depend on. Returns the
//  unwrapped entities and throws `APIError`.
//

import UIKit

protocol AccountSettingRepositoryProtocol {
    func fetchProfileSetting() async throws -> AccountSettingResponse
    func patchProfileSetting(request: SaveAccountRequest) async throws -> AccountSettingResponse
    func deviceLogout(id: Int) async throws -> AccountSettingResponse
    func deviceLogoutAll() async throws -> AccountSettingResponse
    func addUserLink(request: AccountLinkRequest) async throws -> [AccountLinkRequest]
    func deleteUserLink(id: Int) async throws
    func uploadAvatar(image: UIImage) async throws -> UploadedAvatarResponse
    func deleteAvatar(id: Int) async throws -> DeleteAvatarResponse
}
