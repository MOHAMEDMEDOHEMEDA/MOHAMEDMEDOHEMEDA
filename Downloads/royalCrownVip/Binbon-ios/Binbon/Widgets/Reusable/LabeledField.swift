//
//  LabeledField.swift
//  Binbon
//
//  Created by Salah Khaled on 20/04/2026.
//

import SwiftUI

struct LabeledField<Content: View>: View {
    let title: String
    var isRequired: Bool = false
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 1) {
                Text(title)
                    .foregroundStyle(.appText)
                if isRequired {
                    Text("*")
                        .foregroundStyle(.red)
                }
            }
            .font(.subheadline)
            
            content()
        }
    }
}
