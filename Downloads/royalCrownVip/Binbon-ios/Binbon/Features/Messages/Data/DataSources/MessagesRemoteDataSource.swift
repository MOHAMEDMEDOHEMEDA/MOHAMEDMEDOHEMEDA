//
//  MessagesRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the Messages list. Mock-backed for now.
//

import Foundation

protocol MessagesRemoteDataSource {
    func loadConversations() async throws -> [MessageConversation]
}

// MARK: - Mock

struct MockMessagesRemoteDataSource: MessagesRemoteDataSource {
    func loadConversations() async throws -> [MessageConversation] {
        MessageConversation.samples
    }
}
