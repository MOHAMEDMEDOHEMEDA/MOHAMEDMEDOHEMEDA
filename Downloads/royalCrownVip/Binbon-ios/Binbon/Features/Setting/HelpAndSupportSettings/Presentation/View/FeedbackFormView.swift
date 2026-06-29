//
//  FeedbackFormView.swift
//  Binbon
//
//  Created by heba elcc on 07/06/2026.
//

import SwiftUI

struct FeedbackFormView: View {
    let subtitle: String
    let placeholder: String
    let onSubmit: (String) async -> Void

    @State private var feedbackText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(subtitle)
                .font(.headline)
                .foregroundStyle(.appText)
                .multilineTextAlignment(.leading)

            TextEditor(text: $feedbackText)
                .font(.footnote)
                .foregroundStyle(.appText)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(.appText.opacity(0.10))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.appText, lineWidth: 1)
                )
                .frame(height: 130)

            HStack {
                Spacer()
                Button(action: {
                    Task {
                        await onSubmit(feedbackText)
                    }
                }) {
                    Text("submit".localized)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.appText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColor.chromeButtonGradient)
                        .cornerRadius(10)
                }

            }

            Spacer()
        }
        .padding(.vertical , 30)
    }
}

#Preview {
    FeedbackFormView(
        subtitle: "Please describe the problem",
        placeholder: "Enter your feedback...",
        onSubmit: { text in print(text) }
    )
}
