//
//  PromotionPackCell.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromotionPackCell: View {
    let pack: PromotionPack
    let currencyCode: String
    let isSelected: Bool
    var accent: Color = AppColor.packTierAccents[0]
    let action: () -> Void

    private let cornerRadius: CGFloat = 10

    private var priceText: String {
        String(format: "%.2f %@", pack.price, currencyCode)
    }
    private var borderColor: Color {
        pack.isRecommended ? AppColor.goalChipSelected : AppColor.textPrimary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(pack.imageURL ?? "play-1")
                    .resizable()
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.reachRange)
                        .font(.caption.weight(.bold))

                    Text(pack.durationText)
                        .font(.system(size: 10))
                        .lineLimit(1)
                }

                Spacer()

                Text(priceText)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 10)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(pack.isRecommended ? AppColor.packRecommendedFill : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) { recommendedBadge }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recommended pill
    @ViewBuilder
    private var recommendedBadge: some View {
        if pack.isRecommended {
            Text("recommended".localized)
                .font(.caption2.weight(.medium))
                .foregroundStyle(AppColor.packRecommendedBadgeText)
                .padding(.horizontal, 7)
                .padding(.vertical, 1)
                .frame(minWidth: 80)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppColor.goalChipSelected)
                )
                .padding(.trailing, 16)
                .offset(y: -8)
        }
    }
}
