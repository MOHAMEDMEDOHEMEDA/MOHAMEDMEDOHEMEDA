//
//  CreatorLinkPaymentView.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct CreatorLinkPaymentView: View {

    @StateObject private var viewModel = CreatorLinkPaymentViewModel()

    var body: some View {
        PaymentMethodsList(
            cards: viewModel.paymentCards,
            wallets: viewModel.paymentWallets,
            onAdd: { viewModel.showAddPaymentAlert = true },
            onDelete: viewModel.deleteCard,
            onPay: viewModel.pay(with:)
        )
        .addPaymentCardAlert(isPresented: $viewModel.showAddPaymentAlert,
                             onAdd: viewModel.addCard)
    }
}

#Preview {
    CreatorLinkPaymentView()
        .padding()
}
