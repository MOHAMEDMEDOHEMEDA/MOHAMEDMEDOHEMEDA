//
//  DisclosureFieldRow.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// A tappable field that shows a selected value (or a grey placeholder) with a
/// trailing disclosure chevron, styled to match `AppTextField`'s white rounded
/// box. Used for picker-style inputs (age, country, …). Wrap in `LabeledField`
/// for a title. The chevron uses `chevron.forward`, which auto-mirrors for RTL.
struct DisclosureFieldRow: View {

    let value: String?
    let placeholder: String
    var leadingFlag: String? = nil
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                if let leadingFlag {
                    Text(leadingFlag)
                }
                Text(value ?? placeholder)
                    .font(.subheadline)
                    .foregroundStyle(value == nil ? Color.gray : Color.black)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white)
                    .strokeBorder(.appText.opacity(0.2), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        DisclosureFieldRow(value: nil, placeholder: "Select age", onTap: {})
        DisclosureFieldRow(value: "Egypt", placeholder: "Select country", leadingFlag: "🇪🇬", onTap: {})
    }
    .padding()
    .background(Color.black)
}
