//
//  AdsSettingsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — ads settings boundary. Returns entities and throws `APIError`.
//

import Foundation

protocol AdsSettingsRepositoryProtocol {
    func fetchAdsSettings() async throws -> AdsSettingResponse
    func updateAdsSettings(request: AdsSettingRequest) async throws -> AdsSettingResponse
}
