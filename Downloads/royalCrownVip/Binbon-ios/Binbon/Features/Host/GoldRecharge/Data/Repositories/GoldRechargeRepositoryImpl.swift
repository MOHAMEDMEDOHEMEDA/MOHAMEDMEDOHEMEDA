//
//  GoldRechargeRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `GoldRechargeRepositoryProtocol`, driving the remote
//  data source.
//

import Foundation

final class GoldRechargeRepositoryImpl: GoldRechargeRepositoryProtocol {

    private let remote: GoldRechargeRemoteDataSource

    init(remote: GoldRechargeRemoteDataSource) {
        self.remote = remote
    }

    func fetchPackages() async throws -> [CoinPackage] {
        try await remote.fetchPackages()
    }
}
