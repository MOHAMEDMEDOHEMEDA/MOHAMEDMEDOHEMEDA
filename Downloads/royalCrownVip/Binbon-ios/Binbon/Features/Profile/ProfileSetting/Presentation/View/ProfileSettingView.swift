//
//  ProfileSettingView.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import SwiftUI

struct ProfileSettingView: View {

    @Environment(\.router) var router
    @Environment(\.storage) var storage
    @ObservedObject private var localizer = Localizer.shared
    @ObservedObject private var theme = ThemeManager.shared
    @State private var profileImage: UIImage? = nil
    @State private var logoutConfirm: Bool = false
    @State private var showLanguagePicker: Bool = false

    @State private var expandedHeight: CGFloat = 220
    @State private var collapsedHeight: CGFloat = 80
    @State private var scrollOffset: CGFloat = 0
    @Namespace private var headerNS

    private var collapseThreshold: CGFloat { expandedHeight * 0.5 }
    private var collapseProgress: CGFloat { min(max(scrollOffset / collapseThreshold, 0), 1) }
    private var isCollapsed: Bool { collapseProgress >= 0.5 }

    var body: some View {
        ZStack(alignment: .top) {
            scrollContent
            headerView
        }
        .appBackground()
        .appNavigation(title: "profile_settings".localized)
//        .overlay {
//            if showLanguagePicker {
//                LanguagePickerSheet(
//                    isPresented: $showLanguagePicker,
//                    current: localizer.language
//                ) { language in
//                    Localizer.shared.change(language: language)
//                }
//                .transition(.opacity)
//                .zIndex(20)
//            }
//        }
//        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: showLanguagePicker)
        .task { profileImage = await Network.shared.image(storage.user?.profilePhoto ?? "") }
        .confirmationDialog(
            "logout_confirmation".localized,
            isPresented: $logoutConfirm,
            titleVisibility: .visible
        ) {
            Button("confirm".localized, role: .destructive) {
                Storage.shared.token = nil
                Storage.shared.user = nil
                router.root(.authSelection)
            }
            Button("cancel".localized) { }
        }
    }

    // MARK: - Scroll Content
    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear.frame(height: expandedHeight)
                Spacer().frame(height: 20)
                listSection
            }
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ScrollOffsetKey.self,
                            value: -geo.frame(in: .named("settingScroll")).minY
                        )
                }
            )
        }
        .coordinateSpace(name: "settingScroll")
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            scrollOffset = max(value, 0)
        }
        .mask(
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: max(expandedHeight - scrollOffset, collapsedHeight))
                Color.black
            }
        )
    }

    // MARK: - Header
    private var headerView: some View {
        let currentHeight = max(expandedHeight - scrollOffset, collapsedHeight)

        return ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Spacer()
                if isCollapsed {
                    collapsedHeader
                } else {
                    expandedHeader
                }
            }
            .frame(height: currentHeight)
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isCollapsed)
        .onPreferenceChange(ExpandedHeightKey.self) { height in
            if height > 0 { expandedHeight = height + 16 }
        }
        .onPreferenceChange(CollapsedHeightKey.self) { height in
            if height > 0 { collapsedHeight = height + 10 }
        }
    }

    // MARK: - Expanded Header
    private var expandedHeader: some View {
        VStack(spacing: 10) {
            
            ProfileImageView.widget(image: profileImage)
                .matchedGeometryEffect(id: "avatar", in: headerNS)
            Button {
                UIPasteboard.general.string = storage.user?.identity
                Toaster.shared.show(.success("square.on.square"), "id_copied_to_clipboard".localized)
            } label: {
                HStack {
                    Image(systemName: "square.on.square")
                    Text("id_label".localizedFormat(storage.user?.identity ?? ""))
                        .font(.footnote)
                        .lineLimit(1)
                }
                .foregroundStyle(.appText)
            }
            .matchedGeometryEffect(id: "idButton", in: headerNS)
//            HStack {
//                Image(systemName: "shield.righthalf.filled")
//                Text("protection_level_average".localized)
//                    .font(.footnote)
//                    .lineLimit(1)
//            }
//            .foregroundStyle(Color.appGold)
            Button {
                //
            } label: {
                Text("Gold ID: أبن سوريا")
                    .frame(minWidth: 140)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.appGold, in: RoundedRectangle(cornerRadius: 16))
                    // Contrasts with the gold fill on Colored and the
                    // ink fill on Light / Dark.
                    .foregroundStyle(AppColor.gradientBottom.opacity(0.9))
            }
            .matchedGeometryEffect(id: "goldId", in: headerNS)

            Button { logoutConfirm = true } label: {
                Text("logout".localized)
                    .frame(minWidth: 120)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(AppColor.buttonGradient, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
            }
            .matchedGeometryEffect(id: "logout", in: headerNS)
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: ExpandedHeightKey.self, value: geo.size.height)
            }
        )
    }

    // MARK: - Collapsed Header
    private var collapsedHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            ProfileImageView.widget(image: profileImage, size: 56, cornerRadius: 12)
                .matchedGeometryEffect(id: "avatar", in: headerNS)

            VStack(alignment: .leading, spacing: 6) {
                Button {
                    UIPasteboard.general.string = storage.user?.identity
                    Toaster.shared.show(.success("square.on.square"), "id_copied_to_clipboard".localized)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.on.square")
                            .font(.system(size: 12))
                        Text("id_label".localizedFormat(storage.user?.identity ?? ""))
                            .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(.appText)
                }
                .matchedGeometryEffect(id: "idButton", in: headerNS)

                Button {
                    //
                } label: {
                    Text("Gold ID: أبن سوريا")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.appGold, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(AppColor.gradientBottom.opacity(0.9))
                }
                .matchedGeometryEffect(id: "goldId", in: headerNS)
            }

            Spacer()

            Button { logoutConfirm = true } label: {
                Text("logout".localized)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColor.buttonGradient, in: Capsule())
                    .foregroundStyle(.white)
            }
            .matchedGeometryEffect(id: "logout", in: headerNS)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: CollapsedHeightKey.self, value: geo.size.height)
            }
        )
    }

    // MARK: - List Section

    private struct SettingItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let action: () -> Void
    }
    
    var listSection: some View {
        
        let list: [SettingItem] = [
            SettingItem(title: "account_settings".localized, icon: "setting-account", action: {
                router.navigate(.accountSetting)
            }),
            SettingItem(title: "privacy_settings".localized, icon: "setting-privacy", action: {
                router.navigate(.privacySetting)
            }),
            SettingItem(title: "security_settings".localized, icon: "setting-security", action: {
                router.navigate(.securitySetting)
            }),
            SettingItem(title: "notification_settings".localized, icon: "setting-notification", action: {
                router.navigate(.notificationSetting)
            }),
            SettingItem(title: "content_digital_privacy_settings".localized, icon: "setting-content", action: {
                router.navigate(.contentPrivacySetting)
            }),
            SettingItem(title: "interaction_settings".localized, icon: "setting-interact", action: {
                router.navigate(.interactionSetting)
            }),
            SettingItem(title: "creators_settings".localized, icon: "setting-creator", action: {
                router.navigate(.creatorsSettings)
            }),
            SettingItem(title: "marketing_settings".localized, icon: "setting-market", action: {
                router.navigate(.marketingSetting)
            }),
            SettingItem(title: "payment_profit_settings".localized, icon: "setting-payment", action: {
                router.navigate(.paymentAndProfitSettings)
            }),
            SettingItem(title: "language_region_settings".localized, icon: "setting-language", action: {
//                showLanguagePicker = true
                router.navigate(.languageRegionView)
            }),
            SettingItem(title: "appearance_theme_settings".localized, icon: "setting-theme", action: {
                router.navigate(.themeSetting)
            }),
            SettingItem(title: "data_cache_settings".localized, icon: "setting-data", action: {
                router.navigate(.dataCacheSettings)
            }),
            SettingItem(title: "live_stream_settings".localized, icon: "setting-live", action: {
                router.navigate(.liveStreamSetting)
            }),
            SettingItem(title: "stories_settings".localized, icon: "setting-story", action: {
                router.navigate(.storiesSettings)
            }),
            SettingItem(title: "ar_settings".localized, icon: "setting-ar", action: {
                //
            }),
            SettingItem(title: "inapp_games_settings".localized, icon: "setting-game", action: {
                router.navigate(.gameSetting)
            }),
            SettingItem(title: "support_help_settings".localized, icon: "setting-support", action: {
                router.navigate(.helpAndSupport)
            }),
            SettingItem(title: "legal_settings".localized, icon: "setting-legal", action: {
                router.navigate(.legalSettings)
            }),
            SettingItem(title: "ads_settings".localized, icon: "setting-ads", action: {
                router.navigate(.adsSetting)
            })
        ]
        
        return VStack(spacing: 8) {
            ForEach(list) { item in
                Button(action: item.action) {
                    HStack(spacing: 16) {
                        Image(item.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .background(AppColor.buttonGradient, in: Capsule())

                        Text(item.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(.appText)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
            }

        }
        .padding(.horizontal, 20)
    }

    // MARK: - Preference Keys
    private struct ExpandedHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    private struct CollapsedHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    private struct ScrollOffsetKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

// MARK: - Language Picker Sheet
private struct LanguagePickerSheet: View {

    @Binding var isPresented: Bool
    let current: Language
    let onSelect: (Language) -> Void

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {

            /// Dimmed backdrop — tap to dismiss
            Color.black.opacity(appeared ? 0.55 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            card
                .offset(y: appeared ? 0 : 420)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { appeared = true }
        }
    }

    // MARK: Card
    private var card: some View {
        VStack(spacing: 18) {

            Capsule()
                .fill(.appText.opacity(0.4))
                .frame(width: 42, height: 5)
                .padding(.top, 12)

            HStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .bold))
                Text("select_language".localized)
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.appText)

            VStack(spacing: 12) {
                ForEach(Language.allCases, id: \.rawValue) { language in
                    row(for: language)
                }
            }
            .padding(.horizontal, 18)

            Button { dismiss() } label: {
                Text("cancel".localized)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.appText.opacity(0.85))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.appText.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.bottom, 34)
        }
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
                .fill(AppColor.backgroundGradient)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28, style: .continuous)
                        .stroke(Color.appGold.opacity(0.55), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.4), radius: 20, y: -6)
                .ignoresSafeArea()
        )
    }

    // MARK: Row
    private func row(for language: Language) -> some View {
        let isSelected = language == current

        return Button {
            if !isSelected { onSelect(language) }
            dismiss()
        } label: {
            HStack(spacing: 14) {
                Text(language.flag)
                    .font(.system(size: 30))
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(.appText.opacity(0.14)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(language.nativeName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.appText)
                    Text(language.englishName)
                        .font(.system(size: 12))
                        .foregroundStyle(.appText.opacity(0.7))
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.appGold : .appText.opacity(0.35), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.appGold)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.appGold.opacity(0.16) : Color.appText.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.appGold : .clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { appeared = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { isPresented = false }
    }
}

#Preview {
    NavigationView {
        ProfileSettingView()
    }
}
