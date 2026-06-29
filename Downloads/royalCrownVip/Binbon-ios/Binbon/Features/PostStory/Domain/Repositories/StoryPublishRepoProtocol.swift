//
//  StoryPublishRepoProtocol.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import Foundation

protocol StoryPublishRepoProtocol {
    func publishStory(_ request: StoryPublishRequest) async -> Result<BaseResponse<StoryPublishResponse>, APIError>
}

extension StoryPublishRepoProtocol {
    func publishStory(draft: StoryDraft) async -> Result<BaseResponse<StoryPublishResponse>, APIError> {
        await publishStory(StoryPublishRequest(from: draft))
    }
}
