//
//  ShareLinkUseCase.swift
//  Binbon
//

import Foundation

/// Fetches the shareable link for the signed-in user's profile.
struct ShareLinkUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute() async throws -> ShareLinkResponse {
        try await repository.shareLink()
    }
}
