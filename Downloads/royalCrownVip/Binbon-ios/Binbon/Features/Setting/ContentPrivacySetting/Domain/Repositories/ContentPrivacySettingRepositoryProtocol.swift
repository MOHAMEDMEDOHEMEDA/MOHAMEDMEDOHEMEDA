//
//  ContentPrivacySettingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — content control settings boundary the use cases depend on.
//  Returns the reused app model as the entity and throws `APIError`.
//

import Foundation

protocol ContentPrivacySettingRepositoryProtocol {
    func fetchContentControlSettings() async throws -> ContentControlSettings
    /// Returns the updated settings plus the server message for the success toast.
    func updateContentControlSettings(request: ContentControlUpdateRequest) async throws -> (settings: ContentControlSettings, message: String?)
}
