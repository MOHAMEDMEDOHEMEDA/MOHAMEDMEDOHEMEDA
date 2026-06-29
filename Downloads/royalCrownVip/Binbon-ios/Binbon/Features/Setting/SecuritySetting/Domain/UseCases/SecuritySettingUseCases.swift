//
//  SecuritySettingUseCases.swift
//  Binbon
//
//  Domain layer — the security-settings data operations, one use case each, all
//  backed by `SecuritySettingRepositoryProtocol`.
//

import Foundation

struct FetchSecuritySettingsUseCase {
    private let repository: SecuritySettingRepositoryProtocol

    init(repository: SecuritySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> SecuritySettingResponse {
        try await repository.fetchSecuritySettings()
    }
}

struct UpdateBiometricUseCase {
    private let repository: SecuritySettingRepositoryProtocol

    init(repository: SecuritySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: BiometricUpdateRequest) async throws -> SecuritySettingResponse {
        try await repository.updateBiometric(request: request)
    }
}

struct Disable2FAUseCase {
    private let repository: SecuritySettingRepositoryProtocol

    init(repository: SecuritySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(password: String) async throws {
        try await repository.disable2FA(password: password)
    }
}

struct FetchSecurityActivityUseCase {
    private let repository: SecuritySettingRepositoryProtocol

    init(repository: SecuritySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int) async throws -> SecurityActivityResponse {
        try await repository.fetchSecurityActivity(page: page)
    }
}

struct FetchLoginHistoryUseCase {
    private let repository: SecuritySettingRepositoryProtocol

    init(repository: SecuritySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int) async throws -> LoginHistoryResponse {
        try await repository.fetchLoginHistory(page: page)
    }
}
