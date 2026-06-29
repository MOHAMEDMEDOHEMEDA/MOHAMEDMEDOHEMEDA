//
//  DataCacheSettingsUseCases.swift
//  Binbon
//
//  Domain layer — data & cache settings operations.
//

import Foundation

struct FetchDataStorageSettingsUseCase {
    private let repository: DataCacheSettingsRepositoryProtocol

    init(repository: DataCacheSettingsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> DataStorageSettingsResponse {
        try await repository.fetchDataStorageSettings()
    }
}

struct UpdateDataStorageSettingsUseCase {
    private let repository: DataCacheSettingsRepositoryProtocol

    init(repository: DataCacheSettingsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: UpdateDataStorageSettingsRequest) async throws -> (settings: DataStorageSettingsResponse, message: String?) {
        try await repository.updateDataStorageSettings(request: request)
    }
}

struct ClearCacheUseCase {
    private let repository: DataCacheSettingsRepositoryProtocol

    init(repository: DataCacheSettingsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.clearCache()
    }
}

struct DeleteMyAccountUseCase {
    private let repository: DataCacheSettingsRepositoryProtocol

    init(repository: DataCacheSettingsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws {
        try await repository.deleteMyAccount()
    }
}

struct ExportPersonalDataUseCase {
    private let repository: DataCacheSettingsRepositoryProtocol

    init(repository: DataCacheSettingsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> String? {
        try await repository.exportPersonalData()
    }
}
