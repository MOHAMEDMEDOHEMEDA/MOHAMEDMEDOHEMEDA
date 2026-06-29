//
//  ReelsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — reels boundary the use cases depend on. Returns app models as
//  entities and throws `APIError`; the concrete implementation lives in Data.
//

import Foundation

protocol ReelsRepositoryProtocol {
    /// Fetches the reels feed.
    func fetchReels() async throws -> [ReelModel]

    /// Persists the like state for a reel.
    func setReelLike(reelID: ReelModel.ID, liked: Bool) async throws

    /// Persists the bookmark state for a reel.
    func setReelBookmark(reelID: ReelModel.ID, bookmarked: Bool) async throws
}
