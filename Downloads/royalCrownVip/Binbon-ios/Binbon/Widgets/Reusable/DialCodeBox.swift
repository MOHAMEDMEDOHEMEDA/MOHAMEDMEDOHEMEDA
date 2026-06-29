//
//  DialCodeBox.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// The small white-outlined dial-code box from the information form: shows the
/// selected country's dial code (or a dash placeholder) with a down chevron,
/// and opens a `CountryListSheet` on tap. Pair with an inline phone text field.
struct DialCodeBox: View {

    @Binding var country: Country?

    @State private var showPicker = false

    var body: some View {
        Button { showPicker = true } label: {
            HStack(spacing: 4) {
                Text(country?.dialCode ?? "—")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.appText)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.appText, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            CountryListSheet(country: $country)
        }
    }
}

#Preview {
    DialCodeBox(country: .constant(nil))
        .padding()
        .appBackground()
}
