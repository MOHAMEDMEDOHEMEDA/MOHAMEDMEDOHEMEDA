//
//  ShareRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — share-contacts boundary the use cases depend on. Returns
//  entities and throws `APIError`.
//

import Foundation

protocol ShareRepositoryProtocol {
    /// People suggested for sharing the post with directly (the contacts row).
    func fetchContacts() async throws -> [ShareContact]
}
