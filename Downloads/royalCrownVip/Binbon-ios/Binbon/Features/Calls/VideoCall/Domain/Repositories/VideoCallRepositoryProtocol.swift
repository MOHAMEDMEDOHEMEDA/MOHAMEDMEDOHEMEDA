//
//  VideoCallRepositoryProtocol.swift
//  Binbon
//

import Foundation

protocol VideoCallRepositoryProtocol {
    func loadSession(contactName: String, avatarURL: String?) async throws -> VideoCallSession
}
