//
//  MessagesRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — Messages boundary the use cases depend on.
//

import Foundation

protocol MessagesRepositoryProtocol {
    func loadConversations() async throws -> [MessageConversation]
}
