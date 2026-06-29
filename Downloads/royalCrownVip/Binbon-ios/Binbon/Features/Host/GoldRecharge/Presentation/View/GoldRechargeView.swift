//
//  GoldRechargeView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//
//  Screen D of the host flow — gold / coin recharge store.
//  Figma: 5:87231 (colorful) / 616:152987 (light) / 237:78135 (dark).
//

import SwiftUI

struct GoldRechargeView: View {

    @StateObject private var viewModel = GoldRechargeViewModel()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 22) {
                SegmentedTabs(titles: viewModel.tabTitles, selection: $viewModel.selectedTab)

                balanceRow

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.packages) { package in
                        packageCard(package)
                    }
                }
                Spacer(minLength: 80)
                customerServiceFooter
            }
            .padding(20)
            .adaptiveContentWidth()
        }
        .appBackground()
        .appNavigation(title: "recharge_gold".localized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { /* TODO: open recharge history */ } label: {
                    HStack(spacing: 6) {
                        coinGlyph(24)
                        Text("history".localized)
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.appText)
                }
            }
        }
    }

    private var balanceRow: some View {
        // Leading-anchored so the total follows the locale (right in Arabic,
        // left in English) instead of being pinned to one side.
        HStack(spacing: 8) {
            coinGlyph(34)
            Text(viewModel.balance.enFormatted)
                .font(.headline.weight(.bold))
                .foregroundStyle(.appText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func packageCard(_ package: CoinPackage) -> some View {
        let isSelected = viewModel.selectedPackageID == package.id
        return Button {
            viewModel.selectedPackageID = package.id
        } label: {
            VStack(spacing: 6) {
                coinGlyph(50)
                Text(package.amount.enFormatted)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(AppColor.coinTileTitle)
                Text(package.price)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.coinTilePrice)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 116)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColor.coinTileBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.appGold, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }

    private var customerServiceFooter: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "headphones").foregroundStyle(.appText)
                Text("customer_service".localized)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.appText)
            }
            Text("recharge_help_question".localized)
                .font(.footnote)
                .foregroundStyle(.appText.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    /// The gold coin image at an explicit size (raster asset → needs `.resizable`).
    private func coinGlyph(_ size: CGFloat) -> some View {
        Image("coin")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

#Preview {
    NavigationStack { GoldRechargeView() }
}
