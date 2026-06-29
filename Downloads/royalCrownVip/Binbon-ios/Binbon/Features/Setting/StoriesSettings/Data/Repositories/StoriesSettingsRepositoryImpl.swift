//
//  StoriesSettingsRepositoryImpl.swift
//  Binbon
//
//  Data layer — wraps the shared `SettingRepo`, unwrapping the transport envelope.
//

import Foundation

final class StoriesSettingsRepositoryImpl: StoriesSettingsRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchStorySettings() async throws -> StorySettingsResponse? {
        try unwrap(await settingRepo.fetchStorySettings())
    }

    func updateStorySettings(request: StorySettingsRequest) async throws -> StorySettingsResponse? {
        try unwrap(await settingRepo.patchStorySettings(request: request))
    }

    private func unwrap(_ result: Result<BaseResponse<StorySettingsResponse>, APIError>) throws -> StorySettingsResponse? {
        switch result {
        case .success(let response):
            return response.data
        case .failure(let error):
            throw error
        }
    }
}
