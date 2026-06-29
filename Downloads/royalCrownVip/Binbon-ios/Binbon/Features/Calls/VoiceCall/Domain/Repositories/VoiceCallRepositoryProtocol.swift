//
//  VoiceCallRepositoryProtocol.swift
//  Binbon
//

import Foundation

protocol VoiceCallRepositoryProtocol {
    func loadSession(
        contactName: String,
        avatarURL: String?,
        avatarAsset: String,
        transitionsToVideo: Bool
    ) async throws -> VoiceCallSession
}
