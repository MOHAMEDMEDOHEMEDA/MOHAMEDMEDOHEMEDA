//
//  DataCacheSettingsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `DataCacheSettingsRepositoryProtocol`. Wraps the shared
//  `SettingRepo`, unwrapping the transport envelope so the domain only sees
//  entities.
//

import Foundation

final class DataCacheSettingsRepositoryImpl: DataCacheSettingsRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchDataStorageSettings() async throws -> DataStorageSettingsResponse {
        switch await settingRepo.fetchSettingsUserDataStorage() {
        case .success(let response):
            guard let settings = response.data else {
                throw APIError(type: .parsing, message: "Empty data storage settings")
            }
            return settings
        case .failure(let error):
            throw error
        }
    }

    func updateDataStorageSettings(request: UpdateDataStorageSettingsRequest) async throws -> (settings: DataStorageSettingsResponse, message: String?) {
        switch await settingRepo.patchSettingsUserDataStorage(request: request) {
        case .success(let response):
            guard let settings = response.data else {
                throw APIError(type: .parsing, message: "Empty data storage settings")
            }
            return (settings, response.message)
        case .failure(let error):
            throw error
        }
    }

    func clearCache() async throws {
        switch await settingRepo.clearCache() {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func deleteMyAccount() async throws {
        switch await settingRepo.deleteMyAccount() {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func exportPersonalData() async throws -> String? {
        switch await settingRepo.exportPersonalData() {
        case .success(let response):
            return response.message
        case .failure(let error):
            throw error
        }
    }
}
