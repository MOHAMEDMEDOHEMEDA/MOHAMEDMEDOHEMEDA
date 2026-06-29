//
//  CreatorStatisticsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

struct CreatorStatisticsView: View {

    @StateObject private var viewModel = CreatorStatisticsViewModel()

    private let statColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 20) {
                            topTabs
                            periodFilter
                        }
                        .padding(.horizontal, 16)
                        
                        switch viewModel.selectedTab {
                        case .overview:
                            overviewSection
                        case .content:
                            contentSection
                                .frame(minHeight: max(0, geo.size.height),
                                       alignment: .top)
                        case .followers:
                            followersSection
                        }
                }
            }
            .adaptiveContentWidth()
            .appBackground()
            .appNavigation(title: "statistics".localized)
        }
    }

    // MARK: - Overview tab
    private var overviewSection: some View {
        VStack(spacing: 20) {
            statsGrid
            CreatorTrendChartCard(points: viewModel.chartPoints)
                .padding(.top, 8)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Content tab
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("most_engaging_videos".localized)
                .font(.title3.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            SegmentedTabsView(
                items: viewModel.contentMetricOptions,
                selection: $viewModel.selectedContentMetric
            ) { $0.localizedTitle }

            LazyVStack(spacing: 16) {
                ForEach(viewModel.contentVideos) { video in
                    ContentVideoRow(video: video)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            AppColor.gradientTop
                .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - Followers tab
    private var followersSection: some View {
        VStack {
            Text("no_follower_analytics_yet".localized)
                .font(.subheadline)
                .foregroundStyle(.appText.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Top tabs
    private var topTabs: some View {
        SegmentedTabs(
            titles: StatisticsTab.allCases.map(\.localizedTitle),
            selection: Binding(
                get: { StatisticsTab.allCases.firstIndex(of: viewModel.selectedTab) ?? 0 },
                set: { viewModel.selectedTab = StatisticsTab.allCases[$0] }
            )
        )
    }

    // MARK: - Period filter
    private var periodFilter: some View {
        SegmentedTabsView(
            items: CreatorViewsPeriod.allCases,
            selection: $viewModel.selectedPeriod
        ) { $0.localizedTitle }
    }

    // MARK: - Stats grid
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

#Preview {
    NavigationView {
        CreatorStatisticsView()
    }
}

// MARK: - Content row
private struct ContentVideoRow: View {

    let video: ContentVideo

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 8) {
                Text(video.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: "views_this_week_format".localized,
                                video.viewsCount.compactFormatted))
                        .font(.caption)

                    Text(Self.dateFormatter.string(from: video.date))
                        .font(.caption)
                        .foregroundStyle(.appText.opacity(0.7))
                }
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        Group {
            if let name = video.thumbnailName {
                Image(name)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(22)
                    .foregroundStyle(Color.appText.opacity(0.55))
            }
        }
        .frame(width: 90, height: 90)
        .background(Color.appText.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE   d-M-yyyy"
        return f
    }()
}
