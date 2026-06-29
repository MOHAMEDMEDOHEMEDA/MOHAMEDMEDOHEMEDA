//
//  PostsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — posts feed boundary the use cases depend on.
//

import Foundation

protocol PostsRepositoryProtocol {
    func loadFeed() async throws -> [PostModel]
}
