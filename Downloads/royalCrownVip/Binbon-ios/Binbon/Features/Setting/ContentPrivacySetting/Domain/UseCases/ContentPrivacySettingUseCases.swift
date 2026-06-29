//
//  ContentPrivacySettingUseCases.swift
//  Binbon
//
//  Domain layer — content control settings operations (load + update).
//

import Foundation

struct FetchContentControlSettingsUseCase {
    private let repository: ContentPrivacySettingRepositoryProtocol

    init(repository: ContentPrivacySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ContentControlSettings {
        try await repository.fetchContentControlSettings()
    }
}

struct UpdateContentControlSettingsUseCase {
    private let repository: ContentPrivacySettingRepositoryProtocol

    init(repository: ContentPrivacySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: ContentControlUpdateRequest) async throws -> (settings: ContentControlSettings, message: String?) {
        try await repository.updateContentControlSettings(request: request)
    }
}
