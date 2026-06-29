//
//  CreateVideoViewLockButton.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewLockButton: View {

    let armed: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(armed ? AnyShapeStyle(AppColor.buttonGradient)
                            : AnyShapeStyle(Color.black.opacity(0.35)))
                .frame(width: 52, height: 52)
                .overlay(
                    Circle().stroke(.white.opacity(armed ? 0.95 : 0.6),
                                    lineWidth: armed ? 2 : 1)
                )

            Image(systemName: armed ? "lock.fill" : "lock.open.fill")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)
        }
        .shadow(color: armed ? AppColor.gold.opacity(0.6) : .black.opacity(0.35),
                radius: armed ? 12 : 5, y: 3)
        .scaleEffect(armed ? 1.18 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: armed)
    }
}
