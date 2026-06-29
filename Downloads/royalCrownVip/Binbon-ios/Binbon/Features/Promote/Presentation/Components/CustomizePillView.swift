//
//  CustomizePillView.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import SwiftUI

struct CustomizePillView: View {
    let action: () -> Void
    let imageName: String

    var label: String = "customize".localized

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(imageName)
                    .resizable()
                    .frame(width: 18, height: 18)

                Text(label)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColor.customizeButtonFill)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
