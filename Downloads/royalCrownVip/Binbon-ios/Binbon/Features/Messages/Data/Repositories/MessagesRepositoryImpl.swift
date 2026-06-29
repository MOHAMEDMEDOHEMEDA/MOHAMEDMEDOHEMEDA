//
//  MessagesRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `MessagesRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class MessagesRepositoryImpl: MessagesRepositoryProtocol {

    private let remote: MessagesRemoteDataSource

    init(remote: MessagesRemoteDataSource) {
        self.remote = remote
    }

    func loadConversations() async throws -> [MessageConversation] {
        try await remote.loadConversations()
    }
}
