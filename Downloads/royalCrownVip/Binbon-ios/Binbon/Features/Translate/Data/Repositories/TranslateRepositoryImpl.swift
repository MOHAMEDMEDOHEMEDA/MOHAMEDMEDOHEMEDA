//
//  TranslateRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `TranslateRepositoryProtocol`, driving the remote data
//  source.
//

import Foundation

final class TranslateRepositoryImpl: TranslateRepositoryProtocol {

    private let remote: TranslateRemoteDataSource

    init(remote: TranslateRemoteDataSource) {
        self.remote = remote
    }

    func getSuggestedLanguages() async throws -> [String] {
        try await remote.getSuggestedLanguages()
    }

    func getAllLanguages() async throws -> [String] {
        try await remote.getAllLanguages()
    }
}
