//
//  FetchGoldPackagesUseCase.swift
//  Binbon
//
//  Domain layer — loads the coin/gold packages for the recharge store.
//

import Foundation

struct FetchGoldPackagesUseCase {
    private let repository: GoldRechargeRepositoryProtocol

    init(repository: GoldRechargeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [CoinPackage] {
        try await repository.fetchPackages()
    }
}
