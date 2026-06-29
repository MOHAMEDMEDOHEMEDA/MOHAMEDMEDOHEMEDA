//
//  ContentPrivacySettingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `ContentPrivacySettingRepositoryProtocol`. Wraps the
//  shared `SettingRepo`, unwrapping the transport envelope so the domain only
//  sees the `ContentControlSettings` entity.
//

import Foundation

final class ContentPrivacySettingRepositoryImpl: ContentPrivacySettingRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchContentControlSettings() async throws -> ContentControlSettings {
        switch await settingRepo.fetchContentControlSettings() {
        case .success(let response):
            guard let settings = response.data else {
                throw APIError(type: .parsing, message: "Empty content control settings")
            }
            return settings
        case .failure(let error):
            throw error
        }
    }

    func updateContentControlSettings(request: ContentControlUpdateRequest) async throws -> (settings: ContentControlSettings, message: String?) {
        switch await settingRepo.patchContentControlSettings(request: request) {
        case .success(let response):
            guard let settings = response.data else {
                throw APIError(type: .parsing, message: "Empty content control settings")
            }
            return (settings, response.message)
        case .failure(let error):
            throw error
        }
    }
}
