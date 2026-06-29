//
//  PrivacySettingUseCases.swift
//  Binbon
//
//  Domain layer — privacy settings operations (load + update).
//

import Foundation

struct FetchPrivacySettingUseCase {
    private let repository: PrivacySettingRepositoryProtocol

    init(repository: PrivacySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> PrivacySettingModel {
        try await repository.fetchPrivacySetting()
    }
}

struct UpdatePrivacySettingUseCase {
    private let repository: PrivacySettingRepositoryProtocol

    init(repository: PrivacySettingRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: PrivacySettingModel) async throws -> String? {
        try await repository.updatePrivacySetting(request: request)
    }
}
