//
//  FAQCell.swift
//  Binbon
//
//  Created by heba elcc on 04/06/2026.
//

import SwiftUI

struct FAQCell: View {
    let title: String?
    let description: String
    let isLast: Bool

    init(
        title: String? = nil,
        description: String,
        isLast: Bool
    ) {
        self.title = title
        self.description = description
        self.isLast = isLast
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                if let title, !title.isEmpty {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.appText)
                }

                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.appText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if !isLast {
                Divider()
                    .background(.appText.opacity(0.5))
            }
        }
        .padding(.top, 14)

    }
}

#Preview {
    FAQCell(
        title: "What is this app?",
        description: "The app is a social short-video platform where users can create, share, and discover content.",
        isLast: false
    )
    .padding(.horizontal, 16)
    .background(AppColor.backgroundGradient)
}
