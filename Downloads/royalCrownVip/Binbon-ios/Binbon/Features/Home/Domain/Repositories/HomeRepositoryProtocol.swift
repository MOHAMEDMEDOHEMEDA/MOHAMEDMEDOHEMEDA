//
//  HomeRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — Home boundary the use cases depend on. Exposes the cached
//  current user; the concrete implementation lives in Data.
//

import Foundation

protocol HomeRepositoryProtocol {
    /// The current user persisted locally, or nil when signed out.
    func currentUser() -> UserResponse?
}
