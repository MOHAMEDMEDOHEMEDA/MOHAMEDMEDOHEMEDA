//
//  PostSettingsSheetAudienceCard.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct PostSettingsSheetAudienceCard: View {

    @Binding var audience: PostSettingsSheet.Audience
    @Binding var defaultAudience: PostSettingsSheet.Audience
    @Binding var showTip: Bool
    let label: (PostSettingsSheet.Audience) -> String
    var onOpenFriends: () -> Void = {}
    var onSetDefault: () -> Void = {}
    var popupVisible: Bool = false
    var popupMessage: String = ""

    private let cardBg = AppColor.sectionSurface

    var body: some View {
        VStack(spacing: 0) {
            Button { showTip = true } label: {
                HStack(spacing: 7) {
                    Text("who_can_see_post".localized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.appText)
                    Image(systemName: "info.circle")
                        .font(.system(size: 13))
                        .foregroundStyle(.appText.opacity(0.7))
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 12)

            PostSettingsSheetAudienceRow(value: .followers, title: label(.followers),
                                         audience: $audience)
            PostSettingsSheetAudienceRow(value: .friends, title: label(.friends),
                                         subtitle: "friends_you_follow".localized, hasChevron: true,
                                         onOpen: onOpenFriends,
                                         audience: $audience)
            PostSettingsSheetAudienceRow(value: .onlyYou, title: label(.onlyYou),
                                         audience: $audience)

            Button { defaultAudience = audience; onSetDefault() } label: {
                Text("set_default_audience".localized)
                    .font(.system(size: 12))
                    .foregroundStyle(.appText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.appText.opacity(0.18), in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
            .overlay(alignment: .top) {
                if popupVisible {
                    PostSettingsSheetDefaultPopup(message: popupMessage)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 280)
                        .offset(y: -54)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .padding(16)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 12))
    }
}
