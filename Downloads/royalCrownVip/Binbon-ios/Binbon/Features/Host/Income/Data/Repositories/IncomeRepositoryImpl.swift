//
//  IncomeRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `IncomeRepositoryProtocol`, driving the remote data
//  source.
//

import Foundation

final class IncomeRepositoryImpl: IncomeRepositoryProtocol {

    private let remote: IncomeRemoteDataSource

    init(remote: IncomeRemoteDataSource) {
        self.remote = remote
    }

    func fetchBreakdown() async throws -> [IncomeCategory] {
        try await remote.fetchBreakdown()
    }
}
