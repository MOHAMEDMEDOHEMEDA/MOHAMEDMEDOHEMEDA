//
//  PaymentAndProfitSettingsView.swift
//  Binbon
//
//  Created by Husayn on 07/06/2026.
//

import SwiftUI

struct PaymentAndProfitSettingsView: View {
    @StateObject var viewModel = PaymentAndProfitSettingsViewModel()

    var body: some View {
        ExpandView {
            Section("view_transaction_history".localized) { transactionHistorySection }
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "payment_profit_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchTransactions() }
    }

    // MARK: - Sections
    private var transactionHistorySection: some View {
        ForEach(viewModel.transactions) { transaction in
            EarnCell(
                coinAmount: transaction.coinAmount,
                price: transaction.price,
                date: transaction.date
            )
            .onAppear {
                viewModel.loadMoreIfNeeded(currentItem: transaction)
            }
        }
    }
}

#Preview {
    PaymentAndProfitSettingsView()
}
