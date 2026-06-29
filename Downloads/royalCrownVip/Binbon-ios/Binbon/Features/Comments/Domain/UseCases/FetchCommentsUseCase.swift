//
//  FetchCommentsUseCase.swift
//  Binbon
//
//  Domain layer — loads the comment thread for a target item.
//

import Foundation

struct FetchCommentsUseCase {
    private let repository: CommentsRepositoryProtocol

    init(repository: CommentsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(targetID: String) async throws -> [CommentModel] {
        try await repository.fetch(targetID: targetID)
    }
}
