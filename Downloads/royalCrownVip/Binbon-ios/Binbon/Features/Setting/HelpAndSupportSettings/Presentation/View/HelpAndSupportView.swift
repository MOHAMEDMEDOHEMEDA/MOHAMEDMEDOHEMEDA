//
//  HelpAndSupportView.swift
//  Binbon
//
//  Created by heba elcc on 04/06/2026.
//

import SwiftUI

struct HelpAndSupportView: View {
    @StateObject var viewModel = HelpAndSupportViewModel()
    @Environment(\.router) var router

    var body: some View {
        ZStack {
            ExpandView {
                Section("faq_section".localized) { faqSection }
                Section("live_support_section".localized) { liveSupportSection }
                Section("report_problem_section".localized) { reportProblemSection }
                Section("send_suggestion_section".localized) {
                    sendSuggestionSection
                }

            }
            .adaptiveContentWidth()
        }
        .appBackground()
        .appNavigation(title: "account_setting".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchSupportFaqs() }
    }

    // MARK: - Sections
    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.faqs.isEmpty {
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 32))
                        .foregroundStyle(.appText.opacity(0.5))

                    Text("No FAQs available")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.appText.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
            } else {
                ForEach(Array(viewModel.faqs.enumerated()), id: \.element.id) { index, faq in
                    FAQCell(
                        title: faq.title,
                        description: faq.description,
                        isLast: index == viewModel.faqs.count - 1
                    )
                }
            }
        }
    }
    private var liveSupportSection: some View {
        HStack() {
            Text("live_support_section".localized)
                .font(.headline)
                .foregroundStyle(.appText)
                .lineLimit(nil)
            Spacer()
            Image("support")
                .resizable()
                .scaledToFill()
                .frame(width: 24, height: 24)
                .foregroundStyle(.appText)

        }
        .padding(.vertical, 30)
        .padding(.trailing, 16)
    }
    private var reportProblemSection: some View {
        FeedbackFormView(
            subtitle: "report_problem_subtitle".localized,
            placeholder: ""
        ) { feedbackText in
            await viewModel.sendReport(message: feedbackText)
        }
    }

    private var sendSuggestionSection: some View {
        FeedbackFormView(
            subtitle: "send_suggestion_subtitle".localized,
            placeholder: ""
        ) { feedbackText in
            await viewModel.sendSuggestion(message: feedbackText)
        }
    }

}

#Preview("Help and Support View") {
    HelpAndSupportView()
}
