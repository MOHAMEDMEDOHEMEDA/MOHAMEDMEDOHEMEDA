//
//  SendToSheetSearchField.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SendToSheetSearchField: View {

    @Binding var query: String

    var body: some View {
        HStack {
            TextField("search".localized, text: $query)
                .font(.system(size: 13))
                .foregroundStyle(.black)
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.black.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }
}
