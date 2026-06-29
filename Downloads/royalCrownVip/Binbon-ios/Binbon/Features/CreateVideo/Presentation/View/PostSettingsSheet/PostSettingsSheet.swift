//
//  PostSettingsSheet.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct PostSettingsSheet: View {

    let videoURL: URL?
    var image: UIImage? = nil
    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    enum Audience: CaseIterable { case followers, friends, onlyYou }

    @State private var audience: Audience = .followers
    @State private var defaultAudience: Audience = .followers
    @State private var allowComments = true
    @State private var allowReuse = true
    @State private var aiContent = false
    @State private var audienceControls = false
    @State private var commercialDisclosure = false
    @State private var showCommercialDisclosure = false
    @State private var showTip = false
    @State private var showFriends = false
    @State private var showDefaultPopup = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color.black.ignoresSafeArea()
                if let videoURL {
                    LoopingPlayer(url: videoURL, volume: 0).ignoresSafeArea()
                } else if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .ignoresSafeArea()
                }

                VStack {
                    HStack {
                        Button(action: onClose) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                PostSettingsSheetPanel(
                    audience: $audience,
                    defaultAudience: $defaultAudience,
                    allowComments: $allowComments,
                    allowReuse: $allowReuse,
                    aiContent: $aiContent,
                    audienceControls: $audienceControls,
                    showCommercialDisclosure: $showCommercialDisclosure,
                    showTip: $showTip,
                    label: label(for:),
                    onClose: onClose,
                    onOpenFriends: { showFriends = true },
                    onSetDefault: confirmDefaultAudience,
                    popupVisible: showDefaultPopup,
                    popupMessage: "default_audience_already".localizedFormat(baseLabel(for: defaultAudience))
                )
                .frame(height: geo.size.height * 0.72)

                if showTip {
                    PostSettingsSheetTooltip(height: geo.size.height, showTip: $showTip)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .fullScreenCover(isPresented: $showCommercialDisclosure) {
            CommercialDisclosureView(isDisclosed: $commercialDisclosure,
                                     onClose: { showCommercialDisclosure = false })
                .localizedLayout()
        }
        .fullScreenCover(isPresented: $showFriends) {
            FriendsView(onClose: { showFriends = false })
                .localizedLayout()
        }
    }

    private func label(for value: Audience) -> String {
        return value == defaultAudience ? "\(baseLabel(for: value)) \("default_marker".localized)" : baseLabel(for: value)
    }

    private func baseLabel(for value: Audience) -> String {
        switch value {
        case .followers: return "audience_followers".localized
        case .friends:   return "audience_friends".localized
        case .onlyYou:   return "audience_only_you".localized
        }
    }

    private func confirmDefaultAudience() {
        withAnimation { showDefaultPopup = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showDefaultPopup = false }
        }
    }
}
