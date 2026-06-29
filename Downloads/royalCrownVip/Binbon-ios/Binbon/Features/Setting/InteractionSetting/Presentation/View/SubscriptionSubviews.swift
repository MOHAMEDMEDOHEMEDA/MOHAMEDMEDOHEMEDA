//
//  SubscriptionSubviews.swift
//  Binbon
//
//  Created by Aya Mashaly on 06/06/2026.
//

import SwiftUI

struct SubscriptionItem: Identifiable {
    let id = UUID()
    let clubName: String
    let price: String
}

struct SubscriptionRow: View {
    let clubName: String
    let price: String
    var onRenew: () -> Void = {}
    var onCancel: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 10) {
            
            ProfileImageView.widget(image: nil, size: 40, cornerRadius: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(clubName)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(3)
                    .multilineTextAlignment(.trailing)
                
                Text(price)
                    .font(.caption)
                    .foregroundStyle(AppColor.secondaryTextColor)
            }
            
            Spacer(minLength: 8)
            
            Button(action: onCancel) {
                Text("cancel_subscription".localized)
                    .font(.caption2.weight(.semibold))
                    .fixedSize(horizontal: true, vertical: false)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .overlay(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1.5))
            }
            
            AppButton(title: "renew_subscription".localized, maxWidth: false, action: onRenew)
        }
        .padding(.vertical, 8)
    }
}

struct SubscriptionContentList: View {
    let subscriptions: [SubscriptionItem]
    var onRenew: (SubscriptionItem) -> Void = { _ in }
    var onCancel: (SubscriptionItem) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 14) {
            ForEach(Array(subscriptions.enumerated()), id: \.element.id) { index, item in
                SubscriptionRow(
                    clubName: item.clubName,
                    price: item.price,
                    onRenew: { onRenew(item) },
                    onCancel: { onCancel(item) }
                )
                if index < subscriptions.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.top, 4)
    }
}
