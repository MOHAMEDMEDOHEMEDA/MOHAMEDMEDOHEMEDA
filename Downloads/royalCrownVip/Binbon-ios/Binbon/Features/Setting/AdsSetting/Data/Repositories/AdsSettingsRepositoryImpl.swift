//
//  AdsSettingsRepositoryImpl.swift
//  Binbon
//
//  Data layer — wraps the shared `SettingRepo`, unwrapping the transport envelope.
//

import Foundation

final class AdsSettingsRepositoryImpl: AdsSettingsRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchAdsSettings() async throws -> AdsSettingResponse {
        try await unwrap(await settingRepo.fetchAdsSettings())
    }

    func updateAdsSettings(request: AdsSettingRequest) async throws -> AdsSettingResponse {
        try await unwrap(await settingRepo.patchAdsSettings(request: request))
    }

    private func unwrap(_ result: Result<BaseResponse<AdsSettingResponse>, APIError>) async throws -> AdsSettingResponse {
        switch result {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty ads settings")
            }
            return data
        case .failure(let error):
            throw error
        }
    }
}
