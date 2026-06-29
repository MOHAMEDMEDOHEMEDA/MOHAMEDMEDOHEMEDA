//
//  FAQDetailView.swift
//  Binbon
//
//  Created by Heba Elcc on 08/06/2026.
//

import SwiftUI

struct FAQDetailView: View {
    @Environment(\.router) var router

    let question: String
    let answer: String

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 25) {
                    Text(question)
                        .font(.headline)
                        .foregroundStyle(.appBlack)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(answer)
                        .font(.subheadline)
                        .foregroundStyle(.appBlack.opacity(0.7))
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)

                FAQFeedbackSection()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.top, 38)
            .padding(.bottom, 16)
            .adaptiveContentWidth()
        }
        .appBackground()
        .appNavigation(title: "")
    }
}

#Preview {
    FAQDetailView(
        question: "How to use Promote?",
        answer: "You can use Promote in one of the two following ways: From the Binbon video: 1. Select the Binbon video that you want to Promote. 2. Tap the 3 dots [...] on the bottom right side of your video's page. 3. Select \"Promote\". From the Profile page: 1. Go to \"Profile\" and tap on the \"=\" icon in the top right corner. 2. Tap \"Business suite\" or \"Creator tools\". 3. Select \"Promote\"."
    )
}
