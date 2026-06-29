//
//  LoadConversationsUseCase.swift
//  Binbon
//
//  Domain layer — loads the Messages conversation list.
//

import Foundation

struct LoadConversationsUseCase {
    private let repository: MessagesRepositoryProtocol

    init(repository: MessagesRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [MessageConversation] {
        try await repository.loadConversations()
    }
}
