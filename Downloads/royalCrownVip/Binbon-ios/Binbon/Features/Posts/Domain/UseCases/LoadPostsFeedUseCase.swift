//
//  LoadPostsFeedUseCase.swift
//  Binbon
//
//  Domain layer — loads the posts feed.
//

import Foundation

struct LoadPostsFeedUseCase {
    private let repository: PostsRepositoryProtocol

    init(repository: PostsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [PostModel] {
        try await repository.loadFeed()
    }
}
