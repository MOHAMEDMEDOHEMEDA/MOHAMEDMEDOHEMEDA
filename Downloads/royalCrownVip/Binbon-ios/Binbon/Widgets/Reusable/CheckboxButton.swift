//
//  CheckboxButton.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// A square checkbox followed by a trailing label. Mirrors `RadioButton`'s API
/// for single boolean toggles (e.g. the "is host voice?" question on the
/// information form). Theme-aware via `.appText` + `Color.appGold`.
struct CheckboxButton: View {

    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(.appText, lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if isOn {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.appGold)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppColor.gradientBottom)
                    }
                }

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.appText)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        CheckboxButton(title: "Is it the host's voice or not?", isOn: true, action: {})
        CheckboxButton(title: "Unchecked option", isOn: false, action: {})
    }
    .padding()
    .background(Color.black)
}
