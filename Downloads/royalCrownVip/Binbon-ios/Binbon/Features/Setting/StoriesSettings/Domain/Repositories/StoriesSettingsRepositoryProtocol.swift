//
//  StoriesSettingsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — story settings boundary. Returns the entity (optional — the
//  endpoint may resolve with no payload) and throws `APIError`.
//

import Foundation

protocol StoriesSettingsRepositoryProtocol {
    func fetchStorySettings() async throws -> StorySettingsResponse?
    func updateStorySettings(request: StorySettingsRequest) async throws -> StorySettingsResponse?
}
