//
//  VideosRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `VideosRepositoryProtocol`, driving the remote data
//  source.
//

import Foundation

final class VideosRepositoryImpl: VideosRepositoryProtocol {

    private let remote: VideosRemoteDataSource

    init(remote: VideosRemoteDataSource) {
        self.remote = remote
    }

    func fetchVideosFeed() async throws -> [VideoModel] {
        try await remote.fetchVideosFeed()
    }
}
