//
//  LiveCategoryGrid.swift
//  Binbon
//
//  Created by Aya Mashaly on 11/06/2026.
//

import SwiftUI

struct LiveCategoryGrid: View {

    let categories: [LiveCategory]
    let onSelect: (LiveCategory) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 4
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories) { category in
                LiveCategoryTile(category: category) {
                    onSelect(category)
                }
            }
        }
    }
}

// MARK: - Tile
private struct LiveCategoryTile: View {

    let category: LiveCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.titleKey.localized)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .lineLimit(2)
                .padding(.horizontal, 4)
                .background(LinearGradient(colors: [Color(hex: "83489C") , Color(hex: "EB7048") ], startPoint: .top, endPoint:.bottom))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColor.liveCategoryTileBorder, lineWidth: 2.5)
                )
        }
        .buttonStyle(.plain)
    }
}
