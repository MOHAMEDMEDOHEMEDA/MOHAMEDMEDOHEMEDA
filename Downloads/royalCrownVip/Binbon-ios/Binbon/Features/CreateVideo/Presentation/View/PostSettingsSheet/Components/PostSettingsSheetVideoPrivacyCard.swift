//
//  PostSettingsSheetVideoPrivacyCard.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetVideoPrivacyCard: View {

    @Binding var allowComments: Bool
    @Binding var allowReuse: Bool

    private let cardBg = AppColor.sectionSurface

    var body: some View {
        VStack(spacing: 19) {
            HStack {
                Text("allow_comments".localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.appText)
                Spacer()
                PostSettingsSheetMiniToggle(isOn: $allowComments)
            }
            PostSettingsSheetToggleRow(title: "allow_content_reuse".localized,
                                       subtitle: "allow_content_reuse_sub".localized,
                                       isOn: $allowReuse)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 12))
    }
}
