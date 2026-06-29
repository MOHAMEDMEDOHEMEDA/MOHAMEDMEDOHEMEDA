//
//  InlineRadio.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// A compact horizontal radio option: a 20pt ring (gold-filled when selected)
/// followed by its title. Lay several side by side for an inline single-select
/// (e.g. the Male / Female gender choice on the information form).
struct InlineRadio: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(.appText, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(Color.appGold)
                            .frame(width: 12, height: 12)
                    }
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.appText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 24) {
        InlineRadio(title: "Male", isSelected: true, action: {})
        InlineRadio(title: "Female", isSelected: false, action: {})
    }
    .padding()
    .appBackground()
}
