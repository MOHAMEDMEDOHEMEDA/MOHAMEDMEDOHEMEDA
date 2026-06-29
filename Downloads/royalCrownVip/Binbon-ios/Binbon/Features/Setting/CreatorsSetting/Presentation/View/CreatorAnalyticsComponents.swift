//
//  CreatorAnalyticsComponents.swift
//  Binbon
//
//  Created by Aya Mashaly on 18/06/2026.
//

import SwiftUI

// MARK: - Stat card
struct CreatorMetricCard: View {
    let title: String
    let value: Int
    let deltaValue: Int
    let changePercent: Int
    let isSelected: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.appGold : .appText)

                Text(value.compactFormatted)
                    .font(.title.weight(.heavy))
                    .foregroundStyle(isSelected ? Color.appGold : .appText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                deltaRow
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.appGold : Color.appText.opacity(0.5),
                            lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var deltaRow: some View {
        let tint: Color = isSelected ? Color.appGold : .appText
        let deltaText = String(format: "delta_format".localized, deltaValue.compactFormatted)
        let pctText = "(" + String(format: "increase_format".localized, changePercent) + ")"
        return HStack(spacing: 6) {
            Text(deltaText)
                .font(.caption.weight(.semibold))
            Image(systemName: "arrow.up")
                .font(.caption2.weight(.bold))
            Text(pctText)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(tint)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

// MARK: - Trend chart card
struct CreatorTrendChartCard: View {

    let points: [ChartPoint]
    var height: CGFloat = 240

    var body: some View {
        VStack(spacing: 8) {
            LineChart(
                points: points,
                height: height,
                showsXAxisLabels: false
            )
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 12)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.appText.opacity(0.10))
            )

            dateLabels
        }
    }

    private var dateLabels: some View {
        let first = points.first?.date
        let last = points.last?.date

        return HStack {
            dateLabel(last)
            Spacer()
            dateLabel(first)
        }
        .padding(.horizontal, 8)
    }

    private func dateLabel(_ date: Date?) -> some View {
        Group {
            if let date = date {
                Text(Self.monthDayFormatter.string(from: date))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.appText)
            }
        }
    }

    private static let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar")
        f.dateFormat = "MMMM d"
        return f
    }()
}

// MARK: - Mock chart series
enum CreatorAnalyticsMock {
    static func wavyWeekTrend() -> [ChartPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let end = calendar.date(from: DateComponents(year: 2026, month: 12, day: 26)) ?? Date()

        let anchors: [Double] = [
            28_000, 32_000, 48_000, 78_000, 95_000,
            115_000, 118_000, 115_000, 108_000, 100_000
        ]
        let sampleCount = 60
        let totalHours = 6 * 24

        return (0..<sampleCount).map { i in
            let t = Double(i) / Double(sampleCount - 1)
            let anchorPos = t * Double(anchors.count - 1)
            let lower = min(Int(anchorPos), anchors.count - 1)
            let upper = min(lower + 1, anchors.count - 1)
            let frac = anchorPos - Double(lower)
            let base = anchors[lower] + (anchors[upper] - anchors[lower]) * frac
            let ripple = sin(t * 14 * .pi) * 3_200
            let hoursFromEnd = Int((1 - t) * Double(totalHours))
            let date = calendar.date(byAdding: .hour, value: -hoursFromEnd, to: end) ?? end
            return ChartPoint(date: date, value: base + ripple)
        }
    }
}

// MARK: - Compact formatting
extension Int {
    var compactFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let absValue = abs(self)
        switch absValue {
        case 1_000_000...:
            return (formatter.string(from: NSNumber(value: Double(self) / 1_000_000)) ?? "") + "M"
        case 1_000...:
            return (formatter.string(from: NSNumber(value: Double(self) / 1_000)) ?? "") + "K"
        default:
            return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        }
    }
}
