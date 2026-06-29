//
//  CommercialDisclosureHelpSection.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CommercialDisclosureHelpSection: View {

    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.appText)
                .fixedSize(horizontal: false, vertical: true)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(.appText.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
