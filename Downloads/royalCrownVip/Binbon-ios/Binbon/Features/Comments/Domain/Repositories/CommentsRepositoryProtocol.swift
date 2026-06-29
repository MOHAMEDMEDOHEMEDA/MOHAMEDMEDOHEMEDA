//
//  CommentsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — the comments boundary the use cases depend on. Returns entities
//  and throws `APIError`.
//

import Foundation

protocol CommentsRepositoryProtocol {
    /// Comments for the item being viewed (a photo post, reel, …) identified by `targetID`.
    func fetch(targetID: String) async throws -> [CommentModel]
}
