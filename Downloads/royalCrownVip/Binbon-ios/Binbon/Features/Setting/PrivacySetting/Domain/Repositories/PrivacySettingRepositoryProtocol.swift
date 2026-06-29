//
//  PrivacySettingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — privacy settings boundary the use cases depend on. Returns the
//  reused app model as the entity and throws `APIError`.
//

import Foundation

protocol PrivacySettingRepositoryProtocol {
    func fetchPrivacySetting() async throws -> PrivacySettingModel
    /// Returns the server message so the UI can surface it in a toast.
    func updatePrivacySetting(request: PrivacySettingModel) async throws -> String?
}
