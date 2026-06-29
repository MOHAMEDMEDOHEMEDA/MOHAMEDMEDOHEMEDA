//
//  FormRow.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// A single information-form row matching the Figma: a leading label (with an
/// optional gold required-asterisk) and a trailing control, closed by a thin
/// hairline divider. `axis: .horizontal` puts the control on the trailing edge
/// of the same line; `.vertical` stacks the control under the label.
struct FormRow<Control: View>: View {

    let label: String
    var isRequired: Bool = false
    var axis: Axis = .horizontal
    var showsDivider: Bool = true
    /// Vertical axis only: render the control ABOVE the label (e.g. photo tiles).
    var labelBelow: Bool = false
    @ViewBuilder var control: () -> Control

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if axis == .horizontal {
                HStack(alignment: .center, spacing: 12) {
                    labelView
                    Spacer(minLength: 8)
                    control()
                }
            } else if labelBelow {
                control()
                labelView
            } else {
                labelView
                control()
            }

            if showsDivider {
                Rectangle()
                    .fill(.appText.opacity(0.2))
                    .frame(height: 1)
            }
        }
    }

    private var labelView: some View {
        HStack(spacing: 3) {
            if isRequired {
                Text("*")
                    .foregroundStyle(AppColor.requiredMark)
            }
            Text(label)
                .foregroundStyle(.appText)
        }
        .font(.subheadline.weight(.semibold))
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    VStack(spacing: 18) {
        FormRow(label: "National ID", isRequired: true) {
            Text("Enter national ID").foregroundStyle(.appText.opacity(0.5)).font(.subheadline)
        }
        FormRow(label: "Anchor Gender", isRequired: true, axis: .vertical) {
            Text("control").foregroundStyle(.appText)
        }
    }
    .padding()
    .appBackground()
}
