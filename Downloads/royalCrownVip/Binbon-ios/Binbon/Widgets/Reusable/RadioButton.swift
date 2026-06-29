//
//  RadioButton.swift
//  Binbon
//
//  Created by Salah Khaled on 09/05/2026.
//

import SwiftUI

struct RadioButton: View {
    
    let title: String
    let isSelect: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    /// Black in light mode, white in dark mode — tracks the active theme,
    /// which drives the color scheme.
    private var circleColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(.appText, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelect {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 16, height: 16)
                    }
                }
                Text(title)
                    .foregroundStyle(.appText)
                    .font(.subheadline.bold())
            }
        }
        .buttonStyle(.plain)
    }
}
