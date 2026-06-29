//
//  VideoCallRepositoryImpl.swift
//  Binbon
//

import Foundation

final class VideoCallRepositoryImpl: VideoCallRepositoryProtocol {

    private let remote: VideoCallRemoteDataSource

    init(remote: VideoCallRemoteDataSource) {
        self.remote = remote
    }

    func loadSession(contactName: String, avatarURL: String?) async throws -> VideoCallSession {
        try await remote.loadSession(contactName: contactName, avatarURL: avatarURL)
    }
}
