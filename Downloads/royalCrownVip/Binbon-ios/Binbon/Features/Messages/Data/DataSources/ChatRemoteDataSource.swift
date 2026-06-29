//
//  ChatRemoteDataSource.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import Foundation

protocol ChatRemoteDataSource {
    func loadThread() async throws -> ChatThread
}

// MARK: - Mock

struct MockChatRemoteDataSource: ChatRemoteDataSource {
    func loadThread() async throws -> ChatThread {
        ChatThread.sample
    }
}
