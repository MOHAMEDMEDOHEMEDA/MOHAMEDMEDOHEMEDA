//
//  IncomeView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//
//  Screen C of the host flow — earnings / income dashboard.
//  Figma: 5:87170 (colorful) / 616:152926 (light) / 237:78074 (dark).
//
//  Three edge-to-edge gradient bands: header (nav + total income),
//  body (month breakdown + legend), and the pinned balance band.
//

import SwiftUI

struct IncomeView: View {

    @Environment(\.router) var router
    @StateObject private var viewModel = IncomeViewModel()
    // Re-renders the page background on in-app theme switches.
    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                breakdownBand
                    .padding(.vertical, 16)
            }

            balanceBand
        }
        .background(pageBackground.ignoresSafeArea())
        .appNavigation(title: "income".localized)
    }

    /// Colored uses the brand gradient (so the nav bar matches the rest of the
    /// app); Light/Dark keep the grouped page look (light-gray / black).
    @ViewBuilder
    private var pageBackground: some View {
        if theme.mode == .colored {
            AppColor.backgroundGradient
        } else {
            AppColor.groupedPageBackground
        }
    }

    // MARK: - Header band (total income)
    private var header: some View {
        // Summary leading, expand chevron trailing — mirrors to match the
        // RTL design (total income on the right, chevron on the left).
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("total_income".localized)
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.85))
                HStack(spacing: 8) {
                    Text(viewModel.totalIncome.enFormatted)
                        .font(.system(size: 25, weight: .heavy))
                        .foregroundStyle(.appText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Image("game-icons_cut-diamond")
                        .foregroundStyle(Color.appGold)
                }
            }
            Spacer()
            Image(systemName: "chevron.down")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(AppColor.panelSurface)
                .ignoresSafeArea(edges: .top)
                .shadow(color: AppColor.authListRowShadowColor, radius: 4, y: 4)
        )
    }

    // MARK: - Body band (edge to edge)
    private var breakdownBand: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                diamondStat("cost", amount: viewModel.cost, bold: true)
                Spacer()
                Image("solar_calendar-bold")
                    .renderingMode(.template)
                    .foregroundStyle(.appText)
                Text(viewModel.monthLabel)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.appText)
            }
            diamondStat("live_broadcast", amount: viewModel.liveBroadcastTotal, bold: false)
            diamondStat("party_house", amount: viewModel.partyHouseTotal, bold: false)

            Rectangle().fill(.appText.opacity(0.25)).frame(height: 1).padding(.vertical, 4)

            ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                legendRow(category, showsInfo: index == 0)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.panelSurface)
    }

    private func diamondStat(_ key: String, amount: Int, bold: Bool) -> some View {
        HStack(spacing: 6) {
            Text("\(key.localized) : \(amount.enFormatted)")
                .font(bold ? .headline.weight(.heavy) : .subheadline)
                .foregroundStyle(.appText)
            Image("game-icons_cut-diamond")
                .font(.footnote)
                .foregroundStyle(Color.appGold)
        }
    }

    private func legendRow(_ category: IncomeCategory, showsInfo: Bool) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(category.color)
                .frame(width: 10, height: 10)
            Text(category.titleKey.localized)
                .font(.subheadline)
                .foregroundStyle(.appText)
            Text(category.amount.enFormatted)
                .font(.subheadline)
                .foregroundStyle(.appText)
            if showsInfo {
                Image(systemName: "questionmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.8))
            }
        }
    }

    // MARK: - Balance band (edge to edge, pinned)
    private var balanceBand: some View {
        VStack(spacing: 14) {
            Text("\("balance".localized) : \(viewModel.balance.enFormatted)")
                .font(.headline.weight(.heavy))
                .foregroundStyle(.appText)

            // Neutral "صرف" look from the Figma, kept tappable so the flow
            // can advance to the recharge screen.
            Button { router.navigate(.goldRecharge) } label: {
                Text("withdraw".localized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.appText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.appText.opacity(0.22))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(AppColor.panelSurface)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    NavigationStack { IncomeView() }
}
