//
//  IncomeViewModel.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class IncomeViewModel: ObservableObject {

    // TODO: Summary totals stay as placeholder state until an earnings summary
    // endpoint (and its entity) exists; the category breakdown is loaded below.
    @Published var totalIncome: Int = 1_330_172
    @Published var monthLabel: String = "6/2025"
    @Published var cost: Int = 0
    @Published var liveBroadcastTotal: Int = 0
    @Published var partyHouseTotal: Int = 0
    @Published var balance: Int = 32

    @Published var categories: [IncomeCategory] = []
    @Published var error: APIError?

    private let fetchBreakdownUseCase: FetchIncomeBreakdownUseCase

    init(fetchBreakdownUseCase: FetchIncomeBreakdownUseCase) {
        self.fetchBreakdownUseCase = fetchBreakdownUseCase
        load()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(fetchBreakdownUseCase: container.makeFetchIncomeBreakdownUseCase())
    }

    func load() {
        Task {
            do {
                categories = try await fetchBreakdownUseCase.execute()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
