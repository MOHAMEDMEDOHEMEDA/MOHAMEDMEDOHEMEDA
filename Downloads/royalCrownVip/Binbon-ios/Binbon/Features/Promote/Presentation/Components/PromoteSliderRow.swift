//
//  PromoteSliderRow.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromoteSliderRow: View {
    let title: String
    let valueText: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var onEdit: (() -> Void)?

    init(title: String,
         valueText: String,
         value: Binding<Double>,
         range: ClosedRange<Double>,
         step: Double = 1,
         onEdit: (() -> Void)? = nil) {
        self.title = title
        self.valueText = valueText
        self._value = value
        self.range = range
        self.step = step
        self.onEdit = onEdit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.regular))
            VStack (alignment: .center, spacing: 6){
                HStack(spacing: 6) {
                    Text(valueText)
                        .font(.caption)

                    Button {
                        onEdit?()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundStyle(AppColor.textPrimary.opacity(0.7))
                    }
                }

                ThemedSlider(value: $value, in: range, step: step)
            }

        }
    }
}

// MARK: - Themed slider
struct ThemedSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 22

    init(value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1) {
        self._value = value
        self.range = range
        self.step = step
    }

    var body: some View {
        GeometryReader { geo in
            let usable = max(geo.size.width - thumbSize, 1)
            let span = range.upperBound - range.lowerBound
            let fraction = span > 0 ? CGFloat((value - range.lowerBound) / span) : 0
            let clamped = min(max(fraction, 0), 1)
            let thumbX = usable * clamped

            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: trackHeight)

                Capsule()
                    .fill(AppColor.sliderMinTrack)
                    .frame(width: thumbX + thumbSize / 2, height: trackHeight)

                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    .offset(x: thumbX)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let x = min(max(0, gesture.location.x - thumbSize / 2), usable)
                        let raw = range.lowerBound + Double(x / usable) * span
                        let stepped = step > 0 ? (raw / step).rounded() * step : raw
                        value = min(max(range.lowerBound, stepped), range.upperBound)
                    }
            )
        }
        .frame(height: 24)
    }
}
