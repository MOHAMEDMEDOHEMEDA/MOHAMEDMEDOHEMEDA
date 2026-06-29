//
//  ReelsRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `ReelsRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class ReelsRepositoryImpl: ReelsRepositoryProtocol {

    private let remote: ReelsRemoteDataSource

    init(remote: ReelsRemoteDataSource) {
        self.remote = remote
    }

    func fetchReels() async throws -> [ReelModel] {
        try await remote.fetchReels()
    }

    func setReelLike(reelID: ReelModel.ID, liked: Bool) async throws {
        try await remote.setReelLike(reelID: reelID, liked: liked)
    }

    func setReelBookmark(reelID: ReelModel.ID, bookmarked: Bool) async throws {
        try await remote.setReelBookmark(reelID: reelID, bookmarked: bookmarked)
    }
}
