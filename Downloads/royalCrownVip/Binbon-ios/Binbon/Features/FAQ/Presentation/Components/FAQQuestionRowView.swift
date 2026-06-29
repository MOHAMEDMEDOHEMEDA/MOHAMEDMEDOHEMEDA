//
//  FAQQuestionRowView.swift
//  Binbon
//
//  Created by heba elcc on 08/06/2026.
//

import Foundation
import SwiftUI

struct FAQQuestionRowView: View {

    let question: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(question)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.appBlack.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding(.horizontal , 17)
        }
        .buttonStyle(.plain)
    }
}
