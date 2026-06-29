//
//  PhotosRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the photos feed. Mock-backed during the
//  current pre-integration phase.
//

import Foundation

protocol PhotosRemoteDataSource {
    func fetchFeed() async throws -> [PhotoPostModel]
}

// MARK: - Mock

struct MockPhotosRemoteDataSource: PhotosRemoteDataSource {
    func fetchFeed() async throws -> [PhotoPostModel] {
        PhotoPostModel.mockFeed
    }
}
