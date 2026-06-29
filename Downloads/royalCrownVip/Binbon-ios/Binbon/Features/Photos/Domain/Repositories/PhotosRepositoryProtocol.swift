//
//  PhotosRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — photos feed boundary the use cases depend on. Returns entities
//  and throws `APIError`.
//

import Foundation

protocol PhotosRepositoryProtocol {
    func fetchFeed() async throws -> [PhotoPostModel]
}
