//
//  GoldRechargeRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the recharge store. Mock-backed during
//  the current pre-integration phase.
//

import Foundation

protocol GoldRechargeRemoteDataSource {
    func fetchPackages() async throws -> [CoinPackage]
}

// MARK: - Mock

struct MockGoldRechargeRemoteDataSource: GoldRechargeRemoteDataSource {

    func fetchPackages() async throws -> [CoinPackage] {
        CoinPackage.mock
    }
}

private extension CoinPackage {
    static let mock: [CoinPackage] = [
        CoinPackage(amount: 1760, price: "CHF 0.50"),
        CoinPackage(amount: 352,  price: "CHF 0.50"),
        CoinPackage(amount: 174,  price: "CHF 0.50"),
        CoinPackage(amount: 1760, price: "CHF 0.50"),
        CoinPackage(amount: 352,  price: "CHF 0.50"),
        CoinPackage(amount: 174,  price: "CHF 0.50"),
        CoinPackage(amount: 352,  price: "CHF 0.50"),
        CoinPackage(amount: 174,  price: "CHF 0.50")
    ]
}
