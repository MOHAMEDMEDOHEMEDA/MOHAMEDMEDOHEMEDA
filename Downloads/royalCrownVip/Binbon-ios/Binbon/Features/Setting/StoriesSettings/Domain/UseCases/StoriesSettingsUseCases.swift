//
//  StoriesSettingsUseCases.swift
//  Binbon
//
//  Domain layer — story settings use cases.
//

import Foundation

struct FetchStorySettingsUseCase {
    private let repository: StoriesSettingsRepositoryProtocol
    init(repository: StoriesSettingsRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> StorySettingsResponse? {
        try await repository.fetchStorySettings()
    }
}

struct UpdateStorySettingsUseCase {
    private let repository: StoriesSettingsRepositoryProtocol
    init(repository: StoriesSettingsRepositoryProtocol) { self.repository = repository }
    func execute(request: StorySettingsRequest) async throws -> StorySettingsResponse? {
        try await repository.updateStorySettings(request: request)
    }
}
