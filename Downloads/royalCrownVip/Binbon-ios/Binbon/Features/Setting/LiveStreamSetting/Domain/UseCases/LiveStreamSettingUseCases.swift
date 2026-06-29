//
//  LiveStreamSettingUseCases.swift
//  Binbon
//
//  Domain layer — live stream settings + schedule operations.
//

import Foundation

struct FetchLiveStreamSettingsUseCase {
    private let repository: LiveStreamSettingRepositoryProtocol

    init(repository: LiveStreamSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> LiveStreamSettingResponse {
        try await repository.fetchLiveStreamSettings()
    }
}

struct UpdateLiveStreamSettingsUseCase {
    private let repository: LiveStreamSettingRepositoryProtocol

    init(repository: LiveStreamSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: LiveStreamUpdateRequest) async throws -> (settings: LiveStreamSettingResponse, message: String?) {
        try await repository.updateLiveStreamSettings(request: request)
    }
}

struct FetchLiveSchedulesUseCase {
    private let repository: LiveStreamSettingRepositoryProtocol

    init(repository: LiveStreamSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> LiveScheduleListResponse {
        try await repository.fetchLiveSchedules()
    }
}

struct CreateLiveScheduleUseCase {
    private let repository: LiveStreamSettingRepositoryProtocol

    init(repository: LiveStreamSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: LiveScheduleRequest) async throws -> String? {
        try await repository.createLiveSchedule(request: request)
    }
}

struct DeleteLiveScheduleUseCase {
    private let repository: LiveStreamSettingRepositoryProtocol

    init(repository: LiveStreamSettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> String? {
        try await repository.deleteLiveSchedule(id: id)
    }
}
