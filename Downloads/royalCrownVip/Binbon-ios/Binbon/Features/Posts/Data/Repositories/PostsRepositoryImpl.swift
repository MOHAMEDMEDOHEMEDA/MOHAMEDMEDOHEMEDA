//
//  PostsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `PostsRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class PostsRepositoryImpl: PostsRepositoryProtocol {

    private let remote: PostsRemoteDataSource

    init(remote: PostsRemoteDataSource) {
        self.remote = remote
    }

    func loadFeed() async throws -> [PostModel] {
        try await remote.loadFeed()
    }
}
