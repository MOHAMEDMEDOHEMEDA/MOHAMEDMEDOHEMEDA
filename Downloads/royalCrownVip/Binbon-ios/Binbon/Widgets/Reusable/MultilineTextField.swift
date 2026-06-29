//
//  MultilineTextField.swift
//  Binbon
//
//  Created by Salah Khaled on 09/05/2026.
//

import SwiftUI

struct MultilineTextField: View {
    
    @Binding var text: String
    let placeholder: String
    var minHeight: CGFloat = 100
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            /// Placeholder text
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(16)
                    .allowsHitTesting(false)
            }
            
            /// Text editor
            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .font(.subheadline)
                .foregroundStyle(.appText)
                .padding(8)
                .scrollContentBackground(.hidden)
                .autocorrectionDisabled()
                .focused($isFocused)
        }
        .background(.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.appText.opacity(isFocused ? 1.0 : 0.2), lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}
