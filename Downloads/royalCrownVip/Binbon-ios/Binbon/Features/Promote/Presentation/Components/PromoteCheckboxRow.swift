//
//  PromoteCheckboxRow.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromoteCheckboxRow: View {
    let text: String
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isChecked ? AppColor.goalChipSelected : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(
                                    isChecked ? AppColor.goalChipSelected : AppColor.textPrimary,
                                    lineWidth: 1.5
                                )
                        )

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppColor.textPrimary)
                    }
                }
                Text(text)
                    .font(.caption)
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
