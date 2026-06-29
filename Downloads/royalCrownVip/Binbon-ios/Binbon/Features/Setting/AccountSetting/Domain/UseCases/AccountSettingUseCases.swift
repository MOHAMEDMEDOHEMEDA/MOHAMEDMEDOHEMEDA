//
//  AccountSettingUseCases.swift
//  Binbon
//
//  Domain layer — account settings operations. One use case per data operation,
//  each delegating to the account settings repository.
//

import UIKit

struct FetchProfileSettingUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AccountSettingResponse {
        try await repository.fetchProfileSetting()
    }
}

struct SaveProfileSettingUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: SaveAccountRequest) async throws -> AccountSettingResponse {
        try await repository.patchProfileSetting(request: request)
    }
}

struct DeviceLogoutUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> AccountSettingResponse {
        try await repository.deviceLogout(id: id)
    }
}

struct DeviceLogoutAllUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AccountSettingResponse {
        try await repository.deviceLogoutAll()
    }
}

struct AddUserLinkUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: AccountLinkRequest) async throws -> [AccountLinkRequest] {
        try await repository.addUserLink(request: request)
    }
}

struct DeleteUserLinkUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.deleteUserLink(id: id)
    }
}

struct UploadAvatarUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(image: UIImage) async throws -> UploadedAvatarResponse {
        try await repository.uploadAvatar(image: image)
    }
}

struct DeleteAvatarUseCase {
    private let repository: AccountSettingRepositoryProtocol

    init(repository: AccountSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> DeleteAvatarResponse {
        try await repository.deleteAvatar(id: id)
    }
}
