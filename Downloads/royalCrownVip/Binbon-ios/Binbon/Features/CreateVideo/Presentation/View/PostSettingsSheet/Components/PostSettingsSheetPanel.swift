//
//  PostSettingsSheetPanel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetPanel: View {

    @Binding var audience: PostSettingsSheet.Audience
    @Binding var defaultAudience: PostSettingsSheet.Audience
    @Binding var allowComments: Bool
    @Binding var allowReuse: Bool
    @Binding var aiContent: Bool
    @Binding var audienceControls: Bool
    @Binding var showCommercialDisclosure: Bool
    @Binding var showTip: Bool
    let label: (PostSettingsSheet.Audience) -> String
    var onClose: () -> Void
    var onOpenFriends: () -> Void = {}
    var onSetDefault: () -> Void = {}
    var popupVisible: Bool = false
    var popupMessage: String = ""

    private let panelBg = AppColor.backgroundGradient

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("settings_title".localized)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.appText)
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.appText)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 21)
            .padding(.vertical, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    PostSettingsSheetAudienceCard(
                        audience: $audience,
                        defaultAudience: $defaultAudience,
                        showTip: $showTip,
                        label: label,
                        onOpenFriends: onOpenFriends,
                        onSetDefault: onSetDefault,
                        popupVisible: popupVisible,
                        popupMessage: popupMessage
                    )
                    PostSettingsSheetSection(title: "video_privacy".localized) {
                        PostSettingsSheetVideoPrivacyCard(
                            allowComments: $allowComments,
                            allowReuse: $allowReuse
                        )
                    }
                    PostSettingsSheetSection(title: "advanced_settings".localized) {
                        PostSettingsSheetAdvancedCard(
                            aiContent: $aiContent,
                            audienceControls: $audienceControls,
                            showCommercialDisclosure: $showCommercialDisclosure
                        )
                    }
                }
                .padding(.horizontal, 21)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .background(panelBg)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
    }
}
