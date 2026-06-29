//
//  PromotePayingPopup.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import SwiftUI

struct PromotePayingPopup: View {
    var label: String = "promote_paying".localized

    @State private var isAnimating = false

    private let cardSize: CGFloat = 135
    private let circleSize: CGFloat = 31
    private let circleOverlap: CGFloat = 13

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 8) {
                HStack(spacing: -circleOverlap) {
                    Circle()
                        .fill(Color(hex: "E14554"))
                        .frame(width: circleSize, height: circleSize)
                        .scaleEffect(isAnimating ? 1.0 : 0.85)

                    Circle()
                        .fill(Color(hex: "83489C"))
                        .frame(width: circleSize, height: circleSize)
                        .scaleEffect(isAnimating ? 0.85 : 1.0)
                }
                .animation(
                    .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                    value: isAnimating
                )

                Text(label)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: cardSize, height: cardSize)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.75))
            )
        }
        .transition(.opacity)
        .onAppear { isAnimating = true }
    }
}
