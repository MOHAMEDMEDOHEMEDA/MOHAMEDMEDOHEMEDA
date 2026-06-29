//
//  LineChart.swift
//  Binbon
//
//  Created by Aya Mashaly on 07/06/2026.
//

import SwiftUI
import Charts

struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct LineChart: View {
    
    let points: [ChartPoint]

    // MARK: - Customization
    var lineColor: Color = .white
    var lineWidth: CGFloat = 1.5
    var gridColor: Color = .white.opacity(0.25)
    var labelColor: Color = .white
    var labelFont: Font = .caption2
    var yTicks: [Double] = [0, 40_000, 80_000, 120_000]
    var height: CGFloat = 200
    var showsXAxisLabels: Bool = true
    var yLabelFormat: (Double) -> String = { $0 == 0 ? "0" : "\(Int($0 / 1_000))K" }
    var xLabelFormat: (Date) -> String = { LineChart.defaultDayMonth.string(from: $0) }
    
    // MARK: - Derived
    private var yDomain: ClosedRange<Double> { 0...(yTicks.max() ?? 0) }
    private var firstDate: Date { points.first?.date ?? Date() }
    private var lastDate:  Date { points.last?.date  ?? Date() }
    
    // MARK: - Body
    var body: some View {
        Chart(points) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Value", point.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(lineColor)
            .lineStyle(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .chartYScale(domain: yDomain)
        .chartYAxis {
            AxisMarks(position: .trailing, values: yTicks) { value in
                AxisGridLine().foregroundStyle(gridColor)
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(yLabelFormat(v))
                            .font(labelFont)
                            .foregroundStyle(labelColor)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: showsXAxisLabels ? [firstDate, lastDate] : []) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(xLabelFormat(date))
                            .font(labelFont)
                            .foregroundStyle(labelColor)
                    }
                }
            }
        }
        .frame(height: height)
    }
    
    // MARK: - Default formatter
    static let defaultDayMonth: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ar")
        f.dateFormat = "d MMMM"
        return f
    }()
}
