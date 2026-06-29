//
//  PostsRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the posts feed. Mock-backed for now; swap
//  in a real posts endpoint later.
//

import Foundation

protocol PostsRemoteDataSource {
    func loadFeed() async throws -> [PostModel]
}

// MARK: - Mock

struct MockPostsRemoteDataSource: PostsRemoteDataSource {
    func loadFeed() async throws -> [PostModel] {
        PostModel.samples
    }
}
