//
//  PaymentSubviews.swift
//  Binbon
//
//  Created by Aya Mashaly on 04/06/2026.
//

import SwiftUI

struct BrandBadge: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 30)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
    }
}

struct PaymentCardRow: View {
    let card: PaymentCard
    var onDelete: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 14) {
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.title3)
            }
            Spacer(minLength: 8)
            
            Text(card.ccv)
                .font(.footnote.weight(.semibold))
            
            Text(card.expiry)
                .font(.footnote.weight(.semibold))
            
            Text(card.maskedNumber)
                .font(.footnote.weight(.semibold))
            
            BrandBadge(imageName: card.brandImage)
        }
    }
}

struct PaymentWalletRow: View {
    let wallet: PaymentWallet
    var onPay: () -> Void = {}

    var body: some View {
        HStack(spacing: 14) {
            AppButton(title: "pay".localized, maxWidth: false, action: onPay)

            Spacer(minLength: 8)

            Text(wallet.title)
                .font(.footnote.weight(.semibold))

            BrandBadge(imageName: wallet.brandImage)
        }
    }
}

struct PaymentMethodsList: View {
    let cards: [PaymentCard]
    let wallets: [PaymentWallet]
    var onAdd: () -> Void = {}
    var onDelete: (PaymentCard) -> Void = { _ in }
    var onPay: (PaymentWallet) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("payment_methods".localized)
                    .font(.footnote.weight(.semibold))

                Spacer()

                AppButton(title: "add_payment_method".localized, maxWidth: false) {
                    onAdd()
                }
            }

            Spacer()

            ForEach(cards) { card in
                PaymentCardRow(card: card) {
                    onDelete(card)
                }
            }

            ForEach(wallets) { wallet in
                PaymentWalletRow(wallet: wallet) {
                    onPay(wallet)
                }
            }
        }
        .padding(.top, 4)
    }
}
