//
//  PostPreviewViewBottomBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostPreviewViewBottomBar: View {

    let chipBackground: Color
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onClose) {
                HStack(spacing: 7) {
                    ZStack {
                        Circle().fill(Color(hex: "3EFFF5")).frame(width: 26, height: 26)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                    }
                    Text("your_story".localized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 43)
                .background(chipBackground, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button(action: onClose) {
                Text("next".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 43)
                    .background(Color(hex: "EB7048"), in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 27)
        .padding(.bottom, 24)
        .padding(.top, 16)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.85)],
                           startPoint: .top, endPoint: .bottom)
        )
    }
}
