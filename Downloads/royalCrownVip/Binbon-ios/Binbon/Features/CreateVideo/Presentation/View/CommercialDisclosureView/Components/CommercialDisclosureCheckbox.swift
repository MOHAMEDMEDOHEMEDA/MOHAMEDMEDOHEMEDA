//
//  CommercialDisclosureCheckbox.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureCheckbox: View {

    let isChecked: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(isChecked ? AnyShapeStyle(LinearGradient(colors:[Color(hex: "EB7048"),Color(hex: "83489C")] , startPoint: .top, endPoint: .bottom))
                                : AnyShapeStyle(Color.clear))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.appText.opacity(0.7), lineWidth: 1)
                        .opacity(isChecked ? 0 : 1)
                )
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 24, height: 24)
    }
}
