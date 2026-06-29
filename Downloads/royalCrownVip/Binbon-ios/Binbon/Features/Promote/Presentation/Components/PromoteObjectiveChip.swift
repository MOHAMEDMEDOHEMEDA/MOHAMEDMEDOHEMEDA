//
//  PromoteObjectiveChip.swift
//  Binbon
//
//  Created by Husayn on 09/06/2026.
//

import SwiftUI

struct PromoteObjectiveChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private let cornerRadius: CGFloat = 10

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(isSelected ? AppColor.goalChipSelected : .promoteText)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isSelected ? Color.clear : AppColor.goalChipUnselected)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppColor.goalChipSelected, lineWidth: isSelected ? 1 : 0)
                )
        }
        .buttonStyle(.plain)
        .fixedSize()
    }
}

#Preview {
    HStack {
        PromoteObjectiveChip(title: "Boost account", isSelected: true, action: {})
        PromoteObjectiveChip(title: "Sales", isSelected: false, action: {})
    }
    .padding()
}
