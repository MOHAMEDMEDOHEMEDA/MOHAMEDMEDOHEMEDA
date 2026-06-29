//
//  LanguageRegionFormField.swift
//  Binbon
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 18/06/2026.


import SwiftUI

struct LanguageRegionFormField<Content: View>: View {

    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.clear)
                    .strokeBorder(.appText.opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
