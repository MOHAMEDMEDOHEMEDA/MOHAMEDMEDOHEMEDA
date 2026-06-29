//
//  CallSideButton.swift
//  Binbon
//
//  Created by Mohamed Magdy on 23/06/2026.
//

import SwiftUI

struct CallSideButton: View {

    let icon: String
    let accessibilityKey: String
    let iconSize: CGFloat
    var isActive: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            ZStack {
                Circle()
                    .fill(isActive
                          ? AnyShapeStyle(AppColor.buttonGradient)
                          : AnyShapeStyle(AppColor.verificationGradient))
                    .frame(width: 47, height: 47)
                    .overlay {
                        if isActive {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 47, height: 47)
                        }
                    }

                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: iconSize, height: iconSize)
            }
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityKey.localized)
    }
}
