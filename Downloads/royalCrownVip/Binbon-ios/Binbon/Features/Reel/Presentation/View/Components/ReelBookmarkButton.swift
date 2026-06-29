//
//  ReelBookmarkButton.swift
//  Binbon
//

import SwiftUI

struct ReelBookmarkButton: View {
    let isBookmarked: Bool
    let count: Int
    let action: () -> Void

    @State private var scale: CGFloat = 1

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "bookmark.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isBookmarked ? Color.appGold : .white)
                    .scaleEffect(scale)
                    .shadow(color: .black.opacity(0.6), radius: 10)

                Text("\(count)")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 4)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onChange(of: isBookmarked) { _, marked in
            scale = marked ? 0.6 : 1.3
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1
            }
        }
    }
}
