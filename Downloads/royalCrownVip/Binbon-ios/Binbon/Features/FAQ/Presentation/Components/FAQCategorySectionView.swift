//
//  FAQCategorySectionView.swift
//  Binbon
//
//  Created by heba elcc on 08/06/2026.
//

import SwiftUI

struct FAQCategorySectionView: View {

    let category: FAQCategory
    let isExpanded: Bool
    let toggle: () -> Void
    let onQuestionTap: (FAQItem) -> Void

    var body: some View {
        VStack(spacing: 0) {

            Button(action: toggle) {
                HStack {
                    Text(category.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.appBlack)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.appGray)
                }
                .padding(.horizontal, 15)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(category.faqs) { faq in
                        FAQQuestionRowView(
                            question: faq.question ?? ""
                        ) {
                            onQuestionTap(faq)
                        }
                    }
                }
                .padding(.horizontal, 17)
                .padding(.top, 10)
            }
        }
    }
}
