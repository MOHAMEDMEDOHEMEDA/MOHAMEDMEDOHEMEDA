//
//  IPSectionCard.swift
//  Binbon
//
//  Created by Aya Mashaly on 09/06/2026.
//

import SwiftUI

struct IPSectionCard<Content: View>: View {
    var title: String? = nil
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            if let title {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppColor.textPrimary)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.hairline, lineWidth: 1)
        )
    }
}
