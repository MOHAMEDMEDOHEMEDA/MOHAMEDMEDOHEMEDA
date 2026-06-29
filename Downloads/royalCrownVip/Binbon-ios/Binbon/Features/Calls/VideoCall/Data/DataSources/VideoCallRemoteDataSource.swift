//
//  VideoCallRemoteDataSource.swift
//  Binbon
//

import Foundation

protocol VideoCallRemoteDataSource {
    func loadSession(contactName: String, avatarURL: String?) async throws -> VideoCallSession
}

final class MockVideoCallRemoteDataSource: VideoCallRemoteDataSource {

    func loadSession(contactName: String, avatarURL: String?) async throws -> VideoCallSession {
        VideoCallSession(
            durationText: "02:24",
            participants: [
                VideoCallParticipant(
                    id: "remote",
                    name: contactName,
                    imageAsset: "call-remote-video",
                    avatarURL: nil,
                    accent: .remote
                ),
                VideoCallParticipant(
                    id: "local",
                    name: "voice_call_local_contact".localized,
                    imageAsset: "call-local-video",
                    avatarURL: nil,
                    accent: .local
                )
            ]
        )
    }
}
