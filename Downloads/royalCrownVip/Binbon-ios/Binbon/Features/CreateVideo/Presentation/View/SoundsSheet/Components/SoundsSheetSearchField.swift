//
//  SoundsSheetSearchField.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SoundsSheetSearchField: View {

    @Binding var query: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(.appText.opacity(0.7))
            TextField("sounds".localized, text: $query)
                .font(.system(size: 14))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appText.opacity(0.3), lineWidth: 1)
        )
    }
}
