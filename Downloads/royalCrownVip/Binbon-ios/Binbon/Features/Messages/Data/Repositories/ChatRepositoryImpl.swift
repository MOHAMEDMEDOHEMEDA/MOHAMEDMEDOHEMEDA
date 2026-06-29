//
//  ChatRepositoryImpl.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import Foundation

final class ChatRepositoryImpl: ChatRepositoryProtocol {

    private let remote: ChatRemoteDataSource

    init(remote: ChatRemoteDataSource) {
        self.remote = remote
    }

    func loadThread() async throws -> ChatThread {
        try await remote.loadThread()
    }
}
