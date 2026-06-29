//
//  PhotoLikeButton.swift
//  Binbon
//

import SwiftUI

struct PhotoLikeButton: View {
    let isLiked: Bool
    let count: String
    let action: () -> Void

    @State private var heartScale: CGFloat = 1
    @State private var splashScale: CGFloat = 1
    @State private var splashOpacity: Double = 0

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                ZStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.red)
                        .scaleEffect(splashScale)
                        .opacity(splashOpacity)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(isLiked ? .red : AppColor.textPrimary)
                        .scaleEffect(heartScale)
                }
                .frame(width: 24, height: 24)

                Text(count)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary)
                    .contentTransition(.numericText())
            }
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
