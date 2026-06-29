//
//  ShortsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — shorts boundary the use cases depend on. Returns app models as
//  entities and throws `APIError`; the concrete implementation lives in Data.
//

import Foundation

protocol ShortsRepositoryProtocol {
    /// Fetches the shorts feed.
    func fetchShorts() async throws -> [ShortModel]

    /// Persists the like state for a short.
    func setShortLike(shortID: ShortModel.ID, liked: Bool) async throws
}
