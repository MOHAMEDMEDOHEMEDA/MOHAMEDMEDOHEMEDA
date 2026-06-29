//
//  CreatorVirtualCurrencyView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 08/06/2026.
//

import SwiftUI

struct CreatorVirtualCurrencyView: View {

    @StateObject private var viewModel = CreatorVirtualCurrencyViewModel()

    private let gridColumns = [GridItem(.flexible(), spacing: 14),
                               GridItem(.flexible(), spacing: 14),
                               GridItem(.flexible(), spacing: 14)]

    var body: some View {
        VStack(spacing: 22) {
            wealthCard
            spendingSection
            giftsSection
        }
        .padding(16)
    }

    // MARK: - Current wealth
    private var wealthCard: some View {
        HStack(spacing: 8) {
            iconBadge("solar_money-bag-bold")
            Text("creator_current_wealth".localized + " :")
                .font(.subheadline.weight(.semibold))
            coinGlyph
            Text(viewModel.currentWealth.formatted(.number))
                .font(.subheadline.weight(.bold))
            Spacer()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .gradientCard()
    }

    // MARK: - Spending information
    private var spendingSection: some View {
        sectionContainer(title: "creator_spending_info".localized, titleInside: true) {
            VStack(spacing: 30) {
                ForEach(viewModel.spending) { period in
                    spendingRow(period)
                }
            }
        }
    }

    private func spendingRow(_ period: CreatorSpendingPeriod) -> some View {
        HStack(spacing: 8) {
            iconBadge(period.icon)
            Text(period.title + ":")
            coinGlyph
                .font(.subheadline.weight(.semibold))
            Text(period.amount.formatted(.number))
                .font(.subheadline.weight(.bold))
            Spacer()
            }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .gradientCard()
    }

    // MARK: - Gifts
    private var giftsSection: some View {
        sectionContainer(title: "creator_your_gifts".localized) {
            LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 14) {
                ForEach(viewModel.gifts) { gift in
                    giftCard(gift)
                }
            }
        }
    }

    private func giftCard(_ gift: CreatorGift) -> some View {
        VStack(spacing: 6) {
            Group {
                if let imageName = gift.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "gift.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
            }
            .frame(height: 72)
            .frame(maxWidth: .infinity)

            Text(gift.name)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 4) {
                coinGlyph
                Text(gift.price.formatted(.number))
                    .font(.caption2.weight(.bold))
            }
        }
        .frame(height: 120)
        .padding(10)
        .frame(maxWidth: .infinity)
        .gradientCard()
    }

    // MARK: - Shared building blocks

    @ViewBuilder
    private func sectionContainer<Content: View>(
        title: String,
        titleInside: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        if titleInside {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle(title)
                content()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(panelBackground)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle(title)
                content()
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(panelBackground)
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var panelBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(AppColor.sectionPanel)
    }

    private func iconBadge(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 36, height: 36)
    }

    private var coinGlyph: some View {
        Image("coin")
            .resizable()
            .scaledToFit()
            .frame(width: 14, height: 14)
    }
}

// MARK: - Gradient card style
private extension View {
    func gradientCard(cornerRadius: CGFloat = 14) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColor.creatorCardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.appGold, lineWidth: 1.5)
            )
    }
}
