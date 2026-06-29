//
//  PostalCodeField.swift
//  Binbon
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 18/06/2026.


import SwiftUI

struct PostalCodeField: View {

    @Binding var text: String

    var body: some View {
        LanguageRegionFormField {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("postal_code_placeholder".localized)
                        .font(.subheadline)
                        .foregroundStyle(.appText.opacity(0.45))
                        .allowsHitTesting(false)
                }

                TextField("", text: $text)
                    .font(.subheadline)
                    .foregroundStyle(.appText)
                    .keyboardType(.numbersAndPunctuation)
                    .autocorrectionDisabled()
            }
        }
    }
}

#Preview {
    PostalCodeField(text: .constant(""))
        .padding()
        .appBackground()
}
