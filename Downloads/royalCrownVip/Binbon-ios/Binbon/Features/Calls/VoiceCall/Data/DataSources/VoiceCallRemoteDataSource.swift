//
//  VoiceCallRemoteDataSource.swift
//  Binbon
//

import Foundation

protocol VoiceCallRemoteDataSource {
    func loadSession(
        contactName: String,
        avatarURL: String?,
        avatarAsset: String,
        transitionsToVideo: Bool
    ) async throws -> VoiceCallSession
}

final class MockVoiceCallRemoteDataSource: VoiceCallRemoteDataSource {

    func loadSession(
        contactName: String,
        avatarURL: String?,
        avatarAsset: String,
        transitionsToVideo: Bool
    ) async throws -> VoiceCallSession {
        VoiceCallSession(
            primaryParticipant: CallParticipant(
                name: contactName,
                avatarURL: avatarURL,
                avatarAsset: avatarAsset
            ),
            transitionsToVideo: transitionsToVideo
        )
    }
}
