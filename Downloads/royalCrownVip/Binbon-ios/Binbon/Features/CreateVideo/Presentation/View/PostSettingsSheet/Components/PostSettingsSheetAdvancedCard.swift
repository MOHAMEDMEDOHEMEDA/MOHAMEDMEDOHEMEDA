//
//  PostSettingsSheetAdvancedCard.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetAdvancedCard: View {

    @Binding var aiContent: Bool
    @Binding var audienceControls: Bool
    @Binding var showCommercialDisclosure: Bool

    private let cardBg = AppColor.sectionSurface

    var body: some View {
        VStack(spacing: 20) {
            Button {
                showCommercialDisclosure = true
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    PostSettingsSheetTextBlock(title: "commercial_disclosure".localized,
                                               subtitle: "commercial_disclosure_sub".localized)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.appText.opacity(0.7))
                }
            }
            .buttonStyle(.plain)

            PostSettingsSheetToggleRow(title: "ai_generated_content".localized,
                                       subtitle: "ai_generated_content_sub".localized,
                                       isOn: $aiContent)
            PostSettingsSheetToggleRow(title: "audience_controls".localized,
                                       subtitle: "audience_controls_sub".localized,
                                       isOn: $audienceControls)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 12))
    }
}
