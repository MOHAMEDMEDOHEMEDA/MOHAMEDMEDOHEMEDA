//
//  LoadChatThreadUseCase.swift
//  Binbon
//
//  Created by Aya Mashaly on 23/06/2026.
//

import Foundation

struct LoadChatThreadUseCase {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> ChatThread {
        try await repository.loadThread()
    }
}
