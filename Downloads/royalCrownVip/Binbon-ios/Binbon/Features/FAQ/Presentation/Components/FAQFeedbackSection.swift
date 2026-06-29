//
//  FAQFeedbackSection.swift
//  Binbon
//
//  Created by heba elcc on 09/06/2026.
//

import SwiftUI

struct FAQFeedbackSection: View {
    @State private var selectedFeedback: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 35) {
            Text("Is your problem resolved?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.appGray)

            HStack(spacing: 10) {
                Button(action: {
                    selectedFeedback = "Yes"
                    print("Feedback: Yes")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.thumbsup")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Yes")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.appGray.opacity(0.15))
                    .foregroundStyle(Color.black)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                Button(action: {
                    selectedFeedback = "No"
                    print("Feedback: No")
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.thumbsdown")
                            .font(.system(size: 16, weight: .semibold))
                        Text("No")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.appGray.opacity(0.15))
                    .foregroundStyle(Color.black)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
    }
}


#Preview {
    FAQFeedbackSection()
}
