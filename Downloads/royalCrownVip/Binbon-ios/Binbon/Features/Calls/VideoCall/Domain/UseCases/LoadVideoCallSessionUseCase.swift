//
//  LoadVideoCallSessionUseCase.swift
//  Binbon
//

import Foundation

struct LoadVideoCallSessionUseCase {

    private let repository: VideoCallRepositoryProtocol

    init(repository: VideoCallRepositoryProtocol) {
        self.repository = repository
    }

    func execute(contactName: String, avatarURL: String?) async throws -> VideoCallSession {
        try await repository.loadSession(contactName: contactName, avatarURL: avatarURL)
    }
}
