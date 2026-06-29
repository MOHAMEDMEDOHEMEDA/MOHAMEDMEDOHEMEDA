//
//  ShortsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `ShortsRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class ShortsRepositoryImpl: ShortsRepositoryProtocol {

    private let remote: ShortsRemoteDataSource

    init(remote: ShortsRemoteDataSource) {
        self.remote = remote
    }

    func fetchShorts() async throws -> [ShortModel] {
        try await remote.fetchShorts()
    }

    func setShortLike(shortID: ShortModel.ID, liked: Bool) async throws {
        try await remote.setShortLike(shortID: shortID, liked: liked)
    }
}
