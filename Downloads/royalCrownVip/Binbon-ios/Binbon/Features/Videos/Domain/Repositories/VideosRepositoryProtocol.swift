//
//  VideosRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — videos-feed boundary the use cases depend on. Returns app
//  models as entities and throws `APIError`; the concrete implementation lives
//  in Data.
//

import Foundation

protocol VideosRepositoryProtocol {
    /// Loads the videos feed.
    func fetchVideosFeed() async throws -> [VideoModel]
}
