//
//  ShareRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for share contacts. Mock-backed during the
//  current pre-integration phase.
//

import Foundation

protocol ShareRemoteDataSource {
    func fetchContacts() async throws -> [ShareContact]
}

// MARK: - Mock

struct MockShareRemoteDataSource: ShareRemoteDataSource {
    func fetchContacts() async throws -> [ShareContact] {
        .mock
    }
}
