//
//  CreatorViewsEarningsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct CreatorViewsEarningsView: View {

    @StateObject private var viewModel = CreatorViewsEarningsViewModel()

    private let statColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                periodFilter
                statsGrid
                CreatorTrendChartCard(points: viewModel.chartPoints)
                    .padding(.top, 8)
            }
            .padding(16)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "creator_views_ads_earnings".localized)
    }

    // MARK: - Period filter
    private var periodFilter: some View {
        SegmentedTabsView(
            items: CreatorViewsPeriod.allCases,
            selection: $viewModel.selectedPeriod
        ) { $0.localizedTitle }
    }

    // MARK: - Stats
    private var statsGrid: some View {
        LazyVGrid(columns: statColumns, alignment: .leading, spacing: 12) {
            ForEach(viewModel.stats) { stat in
                CreatorMetricCard(
                    title: stat.metric.localizedTitle,
                    value: stat.value,
                    deltaValue: stat.deltaValue,
                    changePercent: stat.changePercent,
                    isSelected: viewModel.selectedMetric == stat.metric
                ) {
                    viewModel.selectedMetric = stat.metric
                }
            }
        }
    }
}
