//
//  PhotoCategoryPill.swift
//  Binbon
//

import SwiftUI

// MARK: - Category pill

struct PhotoCategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.horizontal, 8)
                .frame(height: 26)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected
                              ? AnyShapeStyle(AppColor.goldAccentGradient)
                              : AnyShapeStyle(LinearGradient(
                                colors: [AppColor.gradientStart, AppColor.gradientEnd],
                                startPoint: .top, endPoint: .bottom)))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColor.gold, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
