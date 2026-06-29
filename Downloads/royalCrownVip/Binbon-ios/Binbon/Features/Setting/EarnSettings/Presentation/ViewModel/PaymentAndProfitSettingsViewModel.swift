//
//  PaymentAndProfitSettingsViewModel.swift
//  Binbon
//
//  Created by Husayn on 07/06/2026.
//

import UIKit
import Combine

@MainActor
final class PaymentAndProfitSettingsViewModel: ObservableObject {

    // MARK: - Properties
    @Published var transactions: [Transaction] = []
    @Published var error: APIError?
    @Published var isLoading: Bool = false

    private var currentPage = 1
    private var hasMorePages = true
    var isPaginating = false

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(settingRepo: container.makeSettingRepo())
    }

    // MARK: - Methods
    func fetchTransactions() {
        currentPage = 1
        hasMorePages = true

        // TODO: Replace with API call
        transactions = [
            Transaction(id: 1, coinAmount: "500", price: "4.99", date: "12 June 2026"),
            Transaction(id: 2, coinAmount: "1000", price: "9.99", date: "10 June 2026"),
            Transaction(id: 3, coinAmount: "2500", price: "19.99", date: "8 June 2026"),
        ]
    }

    func loadMoreIfNeeded(currentItem: Transaction) {
        guard currentItem.id == transactions.last?.id,
              hasMorePages,
              !isPaginating else { return }

        currentPage += 1
        isPaginating = true

        // TODO: Replace with API call for next page
        // Task {
        //     defer { isPaginating = false }
        //     let result = await settingRepo.fetchTransactions(page: currentPage)
        //     switch result {
        //     case .success(let response):
        //         transactions.append(contentsOf: response.data ?? [])
        //         hasMorePages = !(response.data?.isEmpty ?? true)
        //     case .failure(let error):
        //         self.error = error
        //     }
        // }
        isPaginating = false
    }

    func isDataNoChanges() -> Bool {
        return true
    }

    func save() {}
}
