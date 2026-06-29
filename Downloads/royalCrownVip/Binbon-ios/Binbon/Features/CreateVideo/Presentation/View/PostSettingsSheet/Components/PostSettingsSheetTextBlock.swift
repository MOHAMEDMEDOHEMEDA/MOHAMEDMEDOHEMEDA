//
//  PostSettingsSheetTextBlock.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetTextBlock: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.appText)
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(.appText.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
