//
//  PrivacySettingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `PrivacySettingRepositoryProtocol`. Wraps the shared
//  `SettingRepo`, unwrapping the transport envelope so the domain only sees the
//  `PrivacySettingModel` entity.
//

import Foundation

final class PrivacySettingRepositoryImpl: PrivacySettingRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchPrivacySetting() async throws -> PrivacySettingModel {
        switch await settingRepo.showPrivacySetting() {
        case .success(let response):
            guard let model = response.data else {
                throw APIError(type: .parsing, message: "Empty privacy settings")
            }
            return model
        case .failure(let error):
            throw error
        }
    }

    func updatePrivacySetting(request: PrivacySettingModel) async throws -> String? {
        switch await settingRepo.patchPrivacySetting(request: request) {
        case .success(let response):
            return response.message
        case .failure(let error):
            throw error
        }
    }
}
