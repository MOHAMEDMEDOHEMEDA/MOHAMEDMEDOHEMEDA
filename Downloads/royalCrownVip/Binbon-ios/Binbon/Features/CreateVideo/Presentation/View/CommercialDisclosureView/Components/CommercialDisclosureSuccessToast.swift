//
//  CommercialDisclosureSuccessToast.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureSuccessToast: View {

    let message: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "4CD964"))
            Text(message)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 16)
        .frame(maxWidth: 308)
        .background(Color.black.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
    }
}
