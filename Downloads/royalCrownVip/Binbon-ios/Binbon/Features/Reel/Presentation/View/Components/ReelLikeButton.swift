//
//  ReelLikeButton.swift
//  Binbon
//

import SwiftUI

struct ReelLikeButton: View {
    let isLiked: Bool
    let count: Int
    let action: () -> Void

    @State private var heartScale: CGFloat = 1
    @State private var splashScale: CGFloat = 1
    @State private var splashOpacity: Double = 0

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: "heart.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.red)
                        .scaleEffect(splashScale)
                        .opacity(splashOpacity)

                    Image(systemName: "heart.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(isLiked ? .red : .white)
                        .scaleEffect(heartScale)
                        .shadow(color: .black.opacity(0.6), radius: 10)
                }

                Text("\(count)")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .shadow(color: .black.opacity(0.6), radius: 4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onChange(of: isLiked) { _, liked in
            if liked {
                heartScale = 0.6
                withAnimation(.spring(response: 0.34, dampingFraction: 0.45)) {
                    heartScale = 1
                }
                splashScale = 0.9
                splashOpacity = 0.85
                withAnimation(.easeOut(duration: 0.5)) {
                    splashScale = 2.3
                    splashOpacity = 0
                }
            } else {
                splashOpacity = 0
                heartScale = 0.8
                withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                    heartScale = 1
                }
            }
        }
    }
}
