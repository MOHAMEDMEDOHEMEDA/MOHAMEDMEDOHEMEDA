//
//  GoldRechargeViewModel.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import Foundation
import Combine

@MainActor
final class GoldRechargeViewModel: ObservableObject {

    // Gold first so it sits at the leading edge (right in Arabic, left in English).
    enum Tab: Int, CaseIterable { case gold, silver }

    @Published var selectedTab: Int = Tab.gold.rawValue
    @Published var balance: Int = 0
    @Published var selectedPackageID: CoinPackage.ID?
    @Published var packages: [CoinPackage] = []
    @Published var error: APIError?

    var tabTitles: [String] {
        ["gold".localized, "silver_coins_games".localized]
    }

    private let fetchPackagesUseCase: FetchGoldPackagesUseCase

    init(fetchPackagesUseCase: FetchGoldPackagesUseCase) {
        self.fetchPackagesUseCase = fetchPackagesUseCase
        load()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(fetchPackagesUseCase: container.makeFetchGoldPackagesUseCase())
    }

    func load() {
        Task {
            do {
                packages = try await fetchPackagesUseCase.execute()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
