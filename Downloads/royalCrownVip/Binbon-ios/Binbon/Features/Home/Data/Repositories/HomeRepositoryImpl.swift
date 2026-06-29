//
//  HomeRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `HomeRepositoryProtocol` backed by local storage.
//  No remote source: the current user is read from persistence, not the network.
//

import Foundation

final class HomeRepositoryImpl: HomeRepositoryProtocol {

    private let storage: Storage

    init(storage: Storage) {
        self.storage = storage
    }

    func currentUser() -> UserResponse? {
        storage.user
    }
}
