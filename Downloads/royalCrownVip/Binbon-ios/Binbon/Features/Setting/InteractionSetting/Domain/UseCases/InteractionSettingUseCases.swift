//
//  InteractionSettingUseCases.swift
//  Binbon
//
//  Domain layer — use cases backing the interaction settings sub-feature.
//

import Foundation

struct FetchInteractionSettingsUseCase {
    private let repository: InteractionSettingRepositoryProtocol

    init(repository: InteractionSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> InteractionSettings {
        try await repository.fetchInteractionSettings()
    }
}

struct UpdateInteractionSettingsUseCase {
    private let repository: InteractionSettingRepositoryProtocol

    init(repository: InteractionSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: UpdateInteractionSettings) async throws {
        try await repository.updateInteractionSettings(request)
    }
}

struct FetchBlockedUsersUseCase {
    private let repository: InteractionSettingRepositoryProtocol

    init(repository: InteractionSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: BlockedUsersRequest) async throws -> BlockedUsersResponse {
        try await repository.fetchBlockedUsers(request)
    }
}

struct BlockUserUseCase {
    private let repository: InteractionSettingRepositoryProtocol

    init(repository: InteractionSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(username: String) async throws {
        try await repository.blockUser(username: username)
    }
}

struct UnblockUserUseCase {
    private let repository: InteractionSettingRepositoryProtocol

    init(repository: InteractionSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws {
        try await repository.unblockUser(id: id)
    }
}

struct FetchInteractionLiveStreamSettingsUseCase {
    private let repository: InteractionSettingRepositoryProtocol

    init(repository: InteractionSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> LiveStreamSettingResponse {
        try await repository.fetchLiveStreamSettings()
    }
}

struct UpdateInteractionLiveStreamSettingsUseCase {
    private let repository: InteractionSettingRepositoryProtocol

    init(repository: InteractionSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: LiveStreamUpdateRequest) async throws -> LiveStreamSettingResponse {
        try await repository.updateLiveStreamSettings(request)
    }
}
