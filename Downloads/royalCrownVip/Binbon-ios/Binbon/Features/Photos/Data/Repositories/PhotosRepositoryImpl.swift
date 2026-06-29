//
//  PhotosRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `PhotosRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class PhotosRepositoryImpl: PhotosRepositoryProtocol {

    private let remote: PhotosRemoteDataSource

    init(remote: PhotosRemoteDataSource) {
        self.remote = remote
    }

    func fetchFeed() async throws -> [PhotoPostModel] {
        try await remote.fetchFeed()
    }
}
