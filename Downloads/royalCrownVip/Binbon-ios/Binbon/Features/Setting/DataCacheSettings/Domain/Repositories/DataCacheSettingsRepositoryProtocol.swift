//
//  DataCacheSettingsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — data & cache settings boundary the use cases depend on.
//  Returns reused app models as entities and throws `APIError`.
//

import Foundation

protocol DataCacheSettingsRepositoryProtocol {
    func fetchDataStorageSettings() async throws -> DataStorageSettingsResponse
    /// Returns the updated settings plus the server message for the success toast.
    func updateDataStorageSettings(request: UpdateDataStorageSettingsRequest) async throws -> (settings: DataStorageSettingsResponse, message: String?)
    func clearCache() async throws
    func deleteMyAccount() async throws
    /// Returns the server message so the UI can surface it in a toast.
    func exportPersonalData() async throws -> String?
}
