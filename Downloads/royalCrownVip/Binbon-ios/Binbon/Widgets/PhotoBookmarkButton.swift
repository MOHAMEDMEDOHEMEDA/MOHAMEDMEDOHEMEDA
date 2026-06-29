//
//  PhotoBookmarkButton.swift
//  Binbon
//

import SwiftUI

struct PhotoBookmarkButton: View {
    let isBookmarked: Bool
    let action: () -> Void

    @State private var scale: CGFloat = 1

    var body: some View {
        Button(action: action) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 20))
                .foregroundStyle(isBookmarked ? AppColor.gold : .white)
                .scaleEffect(scale)
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
