//
//  PromoteRadioRow.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromoteRadioRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))

                Spacer()

                PromoteRadioDot(isSelected: isSelected)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
