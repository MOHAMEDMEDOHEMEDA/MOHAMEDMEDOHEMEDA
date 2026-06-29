//
//  CommentsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `CommentsRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class CommentsRepositoryImpl: CommentsRepositoryProtocol {

    private let remote: CommentsRemoteDataSource

    init(remote: CommentsRemoteDataSource) {
        self.remote = remote
    }

    func fetch(targetID: String) async throws -> [CommentModel] {
        try await remote.fetch(targetID: targetID)
    }
}
