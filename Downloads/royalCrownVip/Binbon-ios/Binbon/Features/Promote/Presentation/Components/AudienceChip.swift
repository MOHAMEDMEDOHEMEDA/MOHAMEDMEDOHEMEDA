//
//  AudienceChip.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import SwiftUI

struct AudienceChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private let cornerRadius: CGFloat = 5

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(isSelected ? AppColor.goalChipSelected : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isSelected ? Color.clear : Color(hex: "ECECEC"), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
