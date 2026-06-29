//
//  LoadVoiceCallSessionUseCase.swift
//  Binbon
//

import Foundation

struct LoadVoiceCallSessionUseCase {

    private let repository: VoiceCallRepositoryProtocol

    init(repository: VoiceCallRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        contactName: String,
        avatarURL: String?,
        avatarAsset: String,
        transitionsToVideo: Bool
    ) async throws -> VoiceCallSession {
        try await repository.loadSession(
            contactName: contactName,
            avatarURL: avatarURL,
            avatarAsset: avatarAsset,
            transitionsToVideo: transitionsToVideo
        )
    }
}
