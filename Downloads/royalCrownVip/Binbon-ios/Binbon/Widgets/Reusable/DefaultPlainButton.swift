//
//  DefaultPlainButton.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 17/06/2026.
//

import SwiftUI


// MARK: - Plain secondary button

struct DefaultPlainButton: View {
    let title: String
    let action: () -> Void
    var color: Color?

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout.bold())
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color ?? Color.appText.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appText.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
//#Preview {
//    DefaultPlainButton(title: "HELLO", action: {
//        
//    })
//}
