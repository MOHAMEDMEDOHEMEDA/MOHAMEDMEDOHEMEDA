//
//  BrandedContentAdsView.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import Combine
import SwiftUI

struct BrandedContentAdsView: View {

    @Binding var isDisclosed: Bool
    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    @State private var selfBrand = false
    @State private var sponsored = false
    @State private var adAuthorization = false
    @State private var anchorAuthorization = true
    @State private var dontShowProfile = true
    @State private var dialog: CommercialDisclosureDialog?
    @State private var showToast = false
    @State private var showHelp = false
    @State private var showAnchor = false

    private let cardBg = AppColor.sectionSurface

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            sectionTitle("cd_section_disclosure")
                            disclosureCard
                            sectionTitle("cd_section_ads")
                            adCard
                            sectionTitle("cd_section_display")
                            displayCard
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 24)
                    }
                    CommercialDisclosureSaveButton(onSave: handleSave)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .adaptiveContentWidth()
                .appBackground()
                .appNavigation(title: "branded_content_ads".localized)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: onClose) {
                            Image(systemName: "chevron.backward")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.appText)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showHelp = true } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 18))
                                .foregroundStyle(.appText)
                        }
                    }
                }
            }

            if showToast {
                VStack {
                    CommercialDisclosureSuccessToast(message: "cd_ads_enabled_toast".localized)
                    Spacer()
                }
                .padding(.top, 8)
                .transition(.opacity)
            }

            if let dialog {
                dialogView(dialog).transition(.opacity)
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onChange(of: isDisclosed) {
            if isDisclosed {
                dialog = .enabledInfo
            } else {
                selfBrand = false
                sponsored = false
                dialog = nil
            }
        }
        .fullScreenCover(isPresented: $showHelp) {
            BrandedContentHelpView(onClose: { showHelp = false })
                .localizedLayout()
        }
        .fullScreenCover(isPresented: $showAnchor) {
            AnchorAuthorizationView(onClose: { showAnchor = false })
                .localizedLayout()
        }
    }

    // MARK: - Cards
    private var disclosureCard: some View {
        VStack(spacing: 0) {
            toggleHeader("disclose_commercial_content", "disclose_commercial_content_sub", $isDisclosed)
            if isDisclosed {
                CommercialDisclosureCheckRow(title: "cd_your_brand_title".localized,
                                             subtitle: "cd_your_brand_sub".localized,
                                             isChecked: $selfBrand)
                    .padding(.top, 28)
                CommercialDisclosureCheckRow(title: "cd_branded_content_title".localized,
                                             subtitle: "cd_branded_content_sub".localized,
                                             isChecked: $sponsored)
                    .padding(.top, 22)
            }
        }
        .padding(16)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 10))
    }

    private var adCard: some View {
        VStack(spacing: 0) {
            toggleHeader("cd_ad_authorization", "cd_ad_authorization_sub", $adAuthorization)
            if adAuthorization {
                detailRow(title: "cd_auth_lasts", subtitle: nil, trailing: pill("cd_extend") {})
                    .padding(.top, 22)
                detailRow(title: "cd_video_code", subtitle: "cd_video_code_sub", trailing: pill("cd_generate") {})
                    .padding(.top, 22)
                anchorRow.padding(.top, 22)
            }
        }
        .padding(16)
        .background(cardBg, in: RoundedRectangle(cornerRadius: 10))
    }

    private var displayCard: some View {
        toggleHeader("cd_dont_show_profile", "cd_dont_show_profile_sub", $dontShowProfile)
            .padding(16)
            .background(cardBg, in: RoundedRectangle(cornerRadius: 10))
    }

    private var anchorRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("cd_anchor_authorization".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.appText)
                Spacer(minLength: 8)
                DiscloseToggle(isOn: $anchorAuthorization)
            }
            Button { showAnchor = true } label: {
                HStack(alignment: .bottom, spacing: 6) {
                    Text("cd_anchor_authorization_sub".localized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.appText.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.appText.opacity(0.7))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Row helpers
    private func sectionTitle(_ key: String) -> some View {
        Text(key.localized)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.appText.opacity(0.6))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggleHeader(_ titleKey: String, _ subKey: String, _ isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey.localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.appText)
                Text(subKey.localized)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.appText.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            DiscloseToggle(isOn: isOn).padding(.top, 2)
        }
    }

    private func detailRow<Trailing: View>(title: String, subtitle: String?,
                                           trailing: Trailing) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.appText)
                if let subtitle {
                    Text(subtitle.localized)
                        .font(.system(size: 12))
                        .foregroundStyle(.appText.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 8)
            trailing
        }
    }

    private func pill(_ key: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(key.localized)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions (mirror the disclosure confirm flow)
    private func handleSave() {
        if isDisclosed {
            withAnimation { dialog = .saveInfo }
        } else {
            onClose()
        }
    }

    private func enableAds() {
        dialog = nil
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation { showToast = false }
        }
    }

    @ViewBuilder
    private func dialogView(_ dialog: CommercialDisclosureDialog) -> some View {
        switch dialog {
        case .enabledInfo:
            CommercialDisclosureConfirmDialog(
                title: "cd_enabled_title".localized,
                message: "cd_enabled_message".localized,
                leftTitle: "cd_back".localized,
                rightTitle: "cd_continue".localized,
                onLeft: { isDisclosed = false },
                onRight: { self.dialog = .enableAds })
        case .enableAds:
            CommercialDisclosureConfirmDialog(
                image: Image("ad-settings"),
                title: "cd_enable_ads_title".localized,
                message: "cd_enable_ads_message".localized,
                leftTitle: "cd_cancel".localized,
                rightTitle: "cd_enable".localized,
                onLeft: { self.dialog = nil },
                onRight: enableAds)
        case .saveInfo:
            CommercialDisclosureConfirmDialog(
                title: "cd_save_title".localized,
                message: "cd_save_message".localized,
                leftTitle: "cd_back".localized,
                rightTitle: "cd_continue".localized,
                onLeft: { self.dialog = nil },
                onRight: { self.dialog = nil; onClose() })
        }
    }
}
