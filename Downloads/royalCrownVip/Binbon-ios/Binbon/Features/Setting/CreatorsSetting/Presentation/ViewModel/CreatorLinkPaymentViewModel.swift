//
//  CreatorLinkPaymentViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import Foundation
import Combine

@MainActor
final class CreatorLinkPaymentViewModel: ObservableObject {
    @Published var paymentCards: [PaymentCard] = [
        PaymentCard(brandImage: "visa",
                    maskedNumber: "*************1548",
                    expiry: "12/2025",
                    ccv: "***"),
        PaymentCard(brandImage: "Mastercard",
                    maskedNumber: "*************1548",
                    expiry: "12/2025",
                    ccv: "***")
    ]

    @Published var paymentWallets: [PaymentWallet] = [
        PaymentWallet(brandImage: "ApplePay",  title: "Apple Pay"),
        PaymentWallet(brandImage: "GooglePay", title: "Google Pay")
    ]

    @Published var showAddPaymentAlert = false

    func addCard(_ card: PaymentCard) {
        paymentCards.append(card)
    }

    func deleteCard(_ card: PaymentCard) {
        paymentCards.removeAll { $0.id == card.id }
    }

    func pay(with wallet: PaymentWallet) {
        // TODO: wire to wallet payment flow
    }
}
