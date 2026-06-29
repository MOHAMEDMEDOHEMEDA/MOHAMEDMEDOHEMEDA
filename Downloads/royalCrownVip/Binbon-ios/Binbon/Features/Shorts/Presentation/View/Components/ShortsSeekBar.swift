//
//  ShortsSeekBar.swift
//  Binbon
//
//  Scrub bar for the shorts player. The played portion and the knob use the
//  brand gradient in the colored theme (plain white otherwise), with a slightly
//  thicker track than the reels bar.
//

import SwiftUI

struct ShortsSeekBar: View {
    let progress: Double
    let isEnabled: Bool
    let onScrubStart: () -> Void
    let onScrub: (Double) -> Void
    let onScrubEnd: (Double) -> Void

    @Environment(\.layoutDirection) private var layoutDirection
    @ObservedObject private var theme = ThemeManager.shared

    @State private var isScrubbing = false
    @State private var dragFraction: Double = 0

    private var fillStyle: AnyShapeStyle {
        theme.mode == .colored ? AnyShapeStyle(AppColor.buttonGradient) : AnyShapeStyle(Color.white)
    }

    private var displayedFraction: Double {
        isScrubbing ? dragFraction : progress
    }

    private var isRTL: Bool { layoutDirection == .rightToLeft }

    private func fraction(forX x: CGFloat, width: CGFloat) -> Double {
        let raw = max(0, min(1, Double(x / width)))
        return isRTL ? 1 - raw : raw
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let clamped = max(0, min(1, displayedFraction))
            let boundaryX = (isRTL ? (1 - clamped) : clamped) * width

            ZStack(alignment: .leading) {
                Color.white.opacity(0.001)

                VStack {
                    Spacer()
                    ZStack(alignment: isRTL ? .trailing : .leading) {
                        Capsule()
                            .fill(Color.white)
                        Capsule()
                            .fill(fillStyle)
                            .frame(width: clamped * width)
                    }
                    .frame(height: isScrubbing ? 6 : 4)
                    Spacer()
                }

                Circle()
                    .fill(fillStyle)
                    .frame(width: isScrubbing ? 18 : 14, height: isScrubbing ? 18 : 14)
                    .shadow(color: .black.opacity(0.4), radius: 2)
                    .position(x: boundaryX, y: geo.size.height / 2)
                    .allowsHitTesting(false)
            }
            .environment(\.layoutDirection, .leftToRight)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard isEnabled, width > 0 else { return }
                        if !isScrubbing {
                            isScrubbing = true
                            onScrubStart()
                        }
                        let f = fraction(forX: value.location.x, width: width)
                        dragFraction = f
                        onScrub(f)
                    }
                    .onEnded { value in
                        guard isEnabled, width > 0 else { return }
                        let f = fraction(forX: value.location.x, width: width)
                        onScrubEnd(f)
                        isScrubbing = false
                    }
            )
            .animation(.easeInOut(duration: 0.15), value: isScrubbing)
        }
        .frame(height: 28)
    }
}
