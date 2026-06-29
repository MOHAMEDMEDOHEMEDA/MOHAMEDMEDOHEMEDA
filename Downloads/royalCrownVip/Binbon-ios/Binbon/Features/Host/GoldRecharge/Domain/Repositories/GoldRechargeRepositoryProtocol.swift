//
//  GoldRechargeRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — recharge-store boundary the use cases depend on. Returns
//  entities and throws `APIError`; the concrete implementation lives in Data.
//

import Foundation

protocol GoldRechargeRepositoryProtocol {
    /// The purchasable coin/gold packages shown in the recharge grid.
    func fetchPackages() async throws -> [CoinPackage]
}
