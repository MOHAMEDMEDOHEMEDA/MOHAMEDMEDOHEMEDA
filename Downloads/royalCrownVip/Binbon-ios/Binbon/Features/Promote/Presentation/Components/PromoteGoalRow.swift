//
//  PromoteGoalRow.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromoteGoalRow: View {
    let goal: PromoteGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(goal.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)

                Text(goal.title)
                    .font(.caption.weight(.medium))

                Spacer()

                PromoteRadioDot(isSelected: isSelected, size: 20)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
