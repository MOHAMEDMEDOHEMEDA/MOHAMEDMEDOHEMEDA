//
//  LiveView.swift
//  Binbon
//
//  Created by Aya Mashaly on 11/06/2026.
//

import SwiftUI

struct LiveView: View {
    
    @Environment(\.router) private var router
    @Environment(\.layoutDirection) private var layoutDirection
    @StateObject private var viewModel = LiveViewModel()
    // Repaint the whole screen (and its tiles/tabs) when the theme switches.
    @ObservedObject private var theme = ThemeManager.shared

    var topInset: CGFloat = 125

    private let earHeight: CGFloat = 39
    private let unionRadius: CGFloat = 12

    /// Thickness of the gold lattice lines drawn between and around the cells.
    private let gridLine: CGFloat = 2

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: gridLine), count: 2)
    }

    var body: some View {
        VStack(spacing: 0) {
            tabLabelRow

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    switch viewModel.selectedSubTab {
                    case .broadcasts: broadcastsContent
                    case .account:    accountContent
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .background { unionBackground }
        .padding(.top, topInset)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
    }

    // MARK: - Sub tabs
    private var tabLabelRow: some View {
        HStack(spacing: 0) {
            ForEach(LiveSubTab.allCases, id: \.self) { tab in
                subTabButton(for: tab)
            }
        }
        .frame(height: earHeight)
    }

    private func subTabButton(for tab: LiveSubTab) -> some View {
        let isSelected = viewModel.selectedSubTab == tab
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedSubTab = tab
            }
        } label: {
            Text(tab.titleKey.localized)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                .foregroundStyle(Color.appText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    // The selected tab's ear fuses with the content panel into one bordered
    // "Union" (Figma 616), while the unselected tab is a separate rounded-top
    // tab behind it. The ear side follows the selected label, flipping for RTL.
    private var unionBackground: some View {
        let earOnLeft = (viewModel.selectedSubTab == .broadcasts) == (layoutDirection == .leftToRight)
        let border = AppColor.liveUnionBorder

        return ZStack {
            LiveUnionInactiveTabShape(leftActive: earOnLeft, earHeight: earHeight, cornerRadius: unionRadius)
                .fill(AppColor.unselectedTabFill)

            // Full gold outline around the unselected tab (not just its top edge),
            // matching the active union ear-border width.
            LiveUnionInactiveTabShape(leftActive: earOnLeft, earHeight: earHeight, cornerRadius: unionRadius)
                .stroke(AppColor.gold, lineWidth: 2)

            LiveUnionShape(leftActive: earOnLeft, earHeight: earHeight, cornerRadius: unionRadius)
                .fill(AppColor.backgroundGradient)

            // Border only on the tab ear — the content container stays unstroked.
            LiveUnionEarBorderShape(leftActive: earOnLeft, earHeight: earHeight, cornerRadius: unionRadius)
                .stroke(border, lineWidth: 2)
        }
    }

    // MARK: - Broadcasts
    private var broadcastsContent: some View {
        VStack(spacing: 20) {
            if let hero = viewModel.hero {
                GoLiveCard(hero: hero, onGoLive: startGoLive)
            }

            LiveCategoryGrid(
                categories: viewModel.categories,
                onSelect: handle(category:)
            )

            broadcastsGrid
        }
    }

    // MARK: - Account
    private var accountContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let hero = viewModel.hero {
                GoLiveCard(hero: hero, onGoLive: startGoLive)
            }

            Text("your_broadcasts".localized)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)

            broadcastsGrid
        }
    }

    // MARK: - Broadcasts grid
    /// One continuous gold lattice: cells sit on a gold background and are inset by
    /// `gridLine`, so the gold shows through as the internal gridlines and the outer
    /// frame. Per-card borders are off and only the outer corners are rounded.
    private var broadcastsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: gridLine) {
            ForEach(viewModel.broadcasts) { broadcast in
                Button { } label: {
                    BroadcastCardView(broadcast: broadcast, cornerRadius: 0, showBorder: false)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(gridLine)
        .background(AppColor.gold)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppColor.gold, lineWidth: gridLine)
        )
    }

    // MARK: - Actions
    private func startGoLive() {}
    
    private func handle(category: LiveCategory) {
        router.navigate(.liveBroadcastsList(category.kind))
    }
}
