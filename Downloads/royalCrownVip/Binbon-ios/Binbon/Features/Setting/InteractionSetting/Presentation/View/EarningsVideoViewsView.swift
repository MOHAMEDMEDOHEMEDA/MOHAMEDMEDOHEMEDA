//
//  EarningsVideoViewsView.swift
//  Binbon
//
//  Created by Aya Mashaly on 07/06/2026.
//

import SwiftUI

struct EarningsVideoViewsView: View {
    
    // MARK: - Filter
    enum DateRange: String, CaseIterable, Identifiable {
        case weekly, monthly, yearly, custom
        var id: String { rawValue }
        var titleKey: String {
            switch self {
            case .weekly:  return "filter_weekly"
            case .monthly: return "filter_monthly"
            case .yearly:  return "filter_yearly"
            case .custom:  return "filter_custom"
            }
        }
    }
    
    @State private var selectedRange: DateRange = .weekly
    @Environment(\.router) private var router
    let points: [ChartPoint]
    
    init(points: [ChartPoint] = EarningsVideoViewsView.sample) {
        self.points = points
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "#8E5B9F").ignoresSafeArea()
            
            VStack(spacing: 25) {
                pills
                    .padding(.top, 20)
                cards
                    .padding(.top, 10)
                chart
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .adaptiveContentWidth()
        }
        .navigationTitle("earnings_video_views".localized)
    }
    
    // MARK: - Filter pills
    private var pills: some View {
        SegmentedTabsView(items: DateRange.allCases, selection: $selectedRange) {
            $0.titleKey.localized
        }
    }
    
    // MARK: - Stat cards
    private var cards: some View {
        HStack(spacing: 14) {
            statCard(titleKey: "views",    value: "99K", delta: "+50K", percent: 98, isOrange: true)
            statCard(titleKey: "earnings", value: "99K", delta: "+50K", percent: 98, isOrange: false)
        }
        .frame(height: 112)
    }
    
    @ViewBuilder
    private func statCard(titleKey: String, value: String, delta: String, percent: Int, isOrange: Bool) -> some View {
        let primary: Color = isOrange ? Color(hex: "#F7A833") : .white
        
        VStack(alignment: .leading, spacing: 6) {
            Text(titleKey.localized)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(primary.opacity(isOrange ? 1 : 0.9))
            
            Text(value)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(primary)
            
            HStack(spacing: 4) {
                Text(delta)
                    .font(.system(size: 9, weight: .semibold))
                
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .bold))
                
                Text(String(format: "increase_format".localized, percent))
                    .font(.system(size: 7, weight: .medium))
            }
            .foregroundStyle(primary.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 7).fill(Color.white.opacity(0.05)))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(isOrange
                        ? AnyShapeStyle(AppColor.buttonGradient)
                        : AnyShapeStyle(Color.white.opacity(0.5)),
                        lineWidth: 1.5)
        )
    }
    
    // MARK: - Chart
    private var chart: some View {
        LineChart(points: points)
    }
    
    // MARK: - Sample
    static let sample: [ChartPoint] = {
        let cal = Calendar(identifier: .gregorian)
        let base = cal.date(from: DateComponents(year: 2025, month: 12, day: 20))!
        let values: [Double] = [8_000, 15_000, 32_000, 58_000, 85_000, 100_000, 62_000]
        return values.enumerated().map { i, v in
            ChartPoint(date: cal.date(byAdding: .day, value: i, to: base)!, value: v)
        }
    }()
}
