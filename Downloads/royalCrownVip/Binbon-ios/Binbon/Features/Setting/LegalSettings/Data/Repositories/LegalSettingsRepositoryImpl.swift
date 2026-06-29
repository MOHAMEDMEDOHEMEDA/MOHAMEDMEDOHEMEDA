//
//  LegalSettingsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `LegalSettingsRepositoryProtocol`. Wraps the shared
//  `SettingRepo` data source, unwrapping the transport envelope so the domain only
//  sees the `LegalContent` entity.
//

import Foundation

final class LegalSettingsRepositoryImpl: LegalSettingsRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchLegalSettings() async throws -> LegalContent {
        switch await settingRepo.fetchLegalSettings() {
        case .success(let response):
            guard let content = response.data else {
                throw APIError(type: .parsing, message: "Empty legal content")
            }
            return content
        case .failure(let error):
            throw error
        }
    }
}
