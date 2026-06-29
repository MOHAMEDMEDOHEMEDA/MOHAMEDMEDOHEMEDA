//
//  VoiceCallRepositoryImpl.swift
//  Binbon
//

import Foundation

final class VoiceCallRepositoryImpl: VoiceCallRepositoryProtocol {

    private let remote: VoiceCallRemoteDataSource

    init(remote: VoiceCallRemoteDataSource) {
        self.remote = remote
    }

    func loadSession(
        contactName: String,
        avatarURL: String?,
        avatarAsset: String,
        transitionsToVideo: Bool
    ) async throws -> VoiceCallSession {
        try await remote.loadSession(
            contactName: contactName,
            avatarURL: avatarURL,
            avatarAsset: avatarAsset,
            transitionsToVideo: transitionsToVideo
        )
    }
}
