//
//  PhotosTopBar.swift
//  Binbon
//

import SwiftUI

// MARK: - Top bar (search + category pills)

struct PhotosTopBar: View {
    @Binding var searchText: String
    @Binding var selectedCategory: PhotoFeedCategory

    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 8) {
                searchField

                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

                Image(systemName: "bell.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColor.textPrimary)
            }

            categorySelector
        }
    }

    private var searchField: some View {
        HStack {
            Text("search".localized)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColor.textPrimary, lineWidth: 1)
        )
    }

    private var categorySelector: some View {
        HStack(spacing: 6) {
            ForEach(PhotoFeedCategory.allCases) { category in
                PhotoCategoryPill(
                    title: category.title,
                    isSelected: selectedCategory == category,
                    action: { selectedCategory = category }
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}
