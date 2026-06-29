//  FrequentlyAskedQuestionsView.swift
//  Binbon
//
//  Created by Heba Elcc on 08/06/2026.
//

import SwiftUI

struct FrequentlyAskedQuestionsView: View {
    @Environment(\.router) var router
    @State private var expandedIndex: Int? = nil

    @State private var faqCategories: [FAQCategory] = [
        FAQCategory(
            id: 1,
            title: "Entrance",
            faqs: [
                FAQItem(id: 1, question: "How to use Promote?", answer: "You can use Promote in one of the two following ways: From the Binbon video: 1. Select the Binbon video that you want to Promote. 2. Tap the 3 dots [...] on the bottom right side of your video's page. 3. Select \"Promote\". From the Profile page: 1. Go to \"Profile\" and tap on the \"=\" icon in the top right corner. 2. Tap \"Business suite\" or \"Creator tools\". 3. Select \"Promote\"."),
                FAQItem(id: 2, question: "Why can't I use Promote in my Country?", answer: "Why can't I use Promote in my Country? Promote is currently only available in selected countries. We are working on releasing the feature to more markets soon--stay tuned!")
            ]
        ),
        FAQCategory(
            id: 2,
            title: "Promote Order Creation",
            faqs: [
                FAQItem(id: 3, question: "What is Promote?", answer: nil),
                FAQItem(id: 4, question: "Who is eligible to use Promote?", answer: nil),
                FAQItem(id: 5, question: "If I am eligible to use Promote, why am I unable to place orders using Promote right now?", answer: nil),
                FAQItem(id: 6, question: "Can I select the target audience by myself?", answer: nil),
                FAQItem(id: 7, question: "Can I select audiences that are out of my country?", answer: nil),
                FAQItem(id: 8, question: "What kinds of interest tags are available for selecting a target audience?", answer: nil),
                FAQItem(id: 9, question: "How will Promotion Pack work for me? Why did you select the budget for me?", answer: nil),
                FAQItem(id: 10, question: "How can I find order detail page?", answer: nil),
                FAQItem(id: 11, question: "Why do I need to change music?", answer: nil),
                FAQItem(id: 12, question: "Why can't I hear my background voice once I change the music?", answer: nil),
                FAQItem(id: 13, question: "How come Promote ask me to change my music?", answer: nil),
                FAQItem(id: 14, question: "How many creatives can I use for one order?", answer: nil),
                FAQItem(id: 15, question: "Can I check Promote data by different creatives?", answer: nil)
            ]
        ),
        FAQCategory(id: 3, title: "Top-up and Payment Inquiries", faqs: [FAQItem(id: 16, question: "What payment methods are available?", answer: nil)]),
        FAQCategory(id: 4, title: "Withdrawal/Refunds and Invoices", faqs: [FAQItem(id: 17, question: "How long does withdrawal take?", answer: nil)]),
        FAQCategory(id: 5, title: "Promote<> TTAM", faqs: [FAQItem(id: 18, question: "What is TTAM?", answer: nil)]),
        FAQCategory(id: 6, title: "Video", faqs: [FAQItem(id: 19, question: "What video formats are supported?", answer: nil)]),
        FAQCategory(id: 7, title: "LIVE", faqs: [FAQItem(id: 20, question: "How to go live?", answer: nil)]),
        FAQCategory(id: 8, title: "Promote for others", faqs: [FAQItem(id: 21, question: "Can I promote others' content?", answer: nil)]),
        FAQCategory(id: 9, title: "Promotion Results", faqs: [FAQItem(id: 22, question: "How are results calculated?", answer: nil)]),
        FAQCategory(id: 10, title: "Coupon/Campaign", faqs: [FAQItem(id: 23, question: "How to use coupons?", answer: nil)]),
        FAQCategory(id: 11, title: "Review", faqs: [FAQItem(id: 24, question: "How is content reviewed?", answer: nil)]),
        FAQCategory(id: 12, title: "Others and Suggestions", faqs: [FAQItem(id: 25, question: "Where can I send suggestions?", answer: nil)])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                ForEach(faqCategories.indices, id: \.self) { index in

                    FAQCategorySectionView(
                        category: faqCategories[index],
                        isExpanded: expandedIndex == index,
                        toggle: {
                            withAnimation {
                                expandedIndex = expandedIndex == index ? nil : index
                            }
                        },
                        onQuestionTap: { faq in
                            router.navigate(
                                .faqDetail(
                                    question: faq.question ?? "",
                                    answer: faq.displayAnswer
                                )
                            )
                        }
                    )
                }
            }
            .padding(.top, 16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(16)
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "Frequently asked questions")
    }
}

#Preview("Frequently Asked Questions") {
    FrequentlyAskedQuestionsView()
}
