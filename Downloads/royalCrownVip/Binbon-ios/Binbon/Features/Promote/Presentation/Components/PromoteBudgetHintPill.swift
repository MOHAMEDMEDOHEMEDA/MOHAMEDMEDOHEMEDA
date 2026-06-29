//
//  PromoteBudgetHintPill.swift
//  Binbon
//
//  Created by Aya Mashaly on 21/06/2026.
//

import SwiftUI

struct PromoteBudgetHintPill: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.thumbsup.fill")
                .font(.system(size: 14))
                .frame(width: 20, height: 20)

            Text(text)
                .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(height: 28)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(AppColor.promoteBudgetHintFill)
        )
    }
}
