//
//  ShareRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `ShareRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class ShareRepositoryImpl: ShareRepositoryProtocol {

    private let remote: ShareRemoteDataSource

    init(remote: ShareRemoteDataSource) {
        self.remote = remote
    }

    func fetchContacts() async throws -> [ShareContact] {
        try await remote.fetchContacts()
    }
}
