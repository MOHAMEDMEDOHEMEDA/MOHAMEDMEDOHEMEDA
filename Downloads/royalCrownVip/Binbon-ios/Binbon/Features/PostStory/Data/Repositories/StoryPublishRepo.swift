//
//  StoryPublishRepo.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import Foundation

final class StoryPublishRepo: Repo, StoryPublishRepoProtocol {

    func publishStory(_ request: StoryPublishRequest) async -> Result<BaseResponse<StoryPublishResponse>, APIError> {
        decodeMock(#"""
        {"status":true,"message":"OK","data":{"story_id":1001,"published_at":"2026-06-18T18:00:00Z"}}
        """#)
    }

    private func decodeMock<T: Decodable>(_ json: String) -> Result<BaseResponse<T>, APIError> {
        guard let data = json.data(using: .utf8) else {
            return .failure(APIError(type: .parsing, message: "Invalid mock JSON"))
        }
        do {
            return .success(try JSONDecoder().decode(BaseResponse<T>.self, from: data))
        } catch {
            return .failure(APIError(type: .parsing, message: "\(error)"))
        }
    }
}
