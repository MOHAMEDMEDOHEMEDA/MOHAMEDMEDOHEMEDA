//
//  PromoteRadioDot.swift
//  Binbon
//
//  Created by Husayn on 08/06/2026.
//

import SwiftUI

struct PromoteRadioDot: View {
    let isSelected: Bool
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColor.textPrimary, lineWidth: 1.5)
                .frame(width: size, height: size)

            if isSelected {
                Circle()
                    .fill(Color.green)
                    .frame(width: size * 0.62, height: size * 0.62)
            }
        }
    }
}
