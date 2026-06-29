//
//  GradientPillButton.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// The primary call-to-action pill from the host flow (Submit / Withdraw):
/// a rounded `AppColor.buttonGradient` bar with centered white-ink title,
/// matching the Figma's coral→purple button. When `isDisabled` it dims to a
/// neutral fill (the grey "صرف" state in the design).
struct GradientPillButton: View {

    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isDisabled
                              ? AnyShapeStyle(Color.appText.opacity(0.25))
                              : AppColor.neutralButtonFill)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        GradientPillButton(title: "Submit", action: {})
        GradientPillButton(title: "Withdraw", isDisabled: true, action: {})
    }
    .padding()
    .appBackground()
}
