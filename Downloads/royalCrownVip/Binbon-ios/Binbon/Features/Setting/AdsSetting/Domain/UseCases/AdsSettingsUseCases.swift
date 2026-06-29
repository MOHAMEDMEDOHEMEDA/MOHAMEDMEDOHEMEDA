//
//  AdsSettingsUseCases.swift
//  Binbon
//
//  Domain layer — ads settings use cases.
//

import Foundation

struct FetchAdsSettingsUseCase {
    private let repository: AdsSettingsRepositoryProtocol
    init(repository: AdsSettingsRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> AdsSettingResponse {
        try await repository.fetchAdsSettings()
    }
}

struct UpdateAdsSettingsUseCase {
    private let repository: AdsSettingsRepositoryProtocol
    init(repository: AdsSettingsRepositoryProtocol) { self.repository = repository }
    func execute(request: AdsSettingRequest) async throws -> AdsSettingResponse {
        try await repository.updateAdsSettings(request: request)
    }
}
