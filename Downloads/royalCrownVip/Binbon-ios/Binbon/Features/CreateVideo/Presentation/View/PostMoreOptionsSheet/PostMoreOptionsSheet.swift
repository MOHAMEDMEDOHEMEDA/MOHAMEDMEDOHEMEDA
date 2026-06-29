//
//  PostMoreOptionsSheet.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

struct PostMoreOptionsSheet: View {

    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared

    @State private var postAsTemplate = false
    @State private var aiContent = false
    @State private var hqUploads = true
    @State private var saveToDevice = true
    @State private var audienceControls = false
    @State private var showCommercialDisclosure = false
    @State private var commercialDisclosed = false
    @State private var showLanguagePicker = false
    @State private var language: VideoLanguage = .english
    @State private var showAcPopup = false
    @State private var showAcDialog = false

    var body: some View {
        ZStack {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    toggleRow("rectangle.on.rectangle", "mo_post_template", "mo_post_template_sub",
                              $postAsTemplate)
                    navRow("megaphone", "mo_content_disclosure_ads", nil, value: nil) {
                        showCommercialDisclosure = true
                    }
                    toggleRow("sparkles", "ai_generated_content", "ai_generated_content_sub", $aiContent)
                    toggleRow("play.rectangle", "mo_hq_uploads", "mo_hq_uploads_sub", $hqUploads)
                    toggleRow("square.and.arrow.down", "mo_save_device", "mo_save_device_sub", $saveToDevice)
                    navRow("globe", "mo_select_language", "mo_select_language_sub",
                           value: language.title) { showLanguagePicker = true }
                    audienceControlsRow
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appBackground()
            .appNavigation(title: "post_more_options".localized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.appText)
                    }
                }
            }
        }

            if showAcDialog {
                CommercialDisclosureConfirmDialog(
                    title: "ac_dialog_title".localized,
                    message: "ac_dialog_body".localized,
                    leftTitle: "cancel".localized,
                    rightTitle: "ok".localized,
                    onLeft: { audienceControls = false; withAnimation { showAcDialog = false } },
                    onRight: { withAnimation { showAcDialog = false } })
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onChange(of: audienceControls) {
            if audienceControls { withAnimation { showAcDialog = true } }
        }
        .fullScreenCover(isPresented: $showCommercialDisclosure) {
            BrandedContentAdsView(isDisclosed: $commercialDisclosed,
                                  onClose: { showCommercialDisclosure = false })
                .localizedLayout()
        }
        .fullScreenCover(isPresented: $showLanguagePicker) {
            VideoLanguagePickerView(selected: $language,
                                    onClose: { showLanguagePicker = false })
                .localizedLayout()
        }
    }

    // MARK: - Rows
    private func toggleRow(_ icon: String, _ titleKey: String, _ subKey: String,
                           _ isOn: Binding<Bool>) -> some View {
        rowContainer(icon, titleKey, subKey) {
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppColor.toggleOnColor)
        }
    }

    private func navRow(_ icon: String, _ titleKey: String, _ subKey: String?,
                        value: String?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            rowContainer(icon, titleKey, subKey) {
                HStack(spacing: 4) {
                    if let value {
                        Text(value)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.appText.opacity(0.7))
                    }
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.appText.opacity(0.6))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func rowContainer<Trailing: View>(_ icon: String, _ titleKey: String, _ subKey: String?,
                                              @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.appText)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(titleKey.localized)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.appText)
                if let subKey {
                    Text(subKey.localized)
                        .font(.system(size: 12))
                        .foregroundStyle(.appText.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 8)
            trailing()
        }
    }

    private var audienceControlsRow: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 18))
                .foregroundStyle(.appText)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("audience_controls".localized)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.appText)
                    Button { withAnimation { showAcPopup.toggle() } } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 13))
                            .foregroundStyle(.appText.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .bottomLeading) {
                        if showAcPopup {
                            acPopup
                                .frame(width: 230)
                                .offset(x: -16, y: -46)
                                .transition(.opacity)
                                .zIndex(1)
                        }
                    }
                }
                Text("audience_controls_sub".localized)
                    .font(.system(size: 12))
                    .foregroundStyle(.appText.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: $audienceControls)
                .labelsHidden()
                .tint(AppColor.toggleOnColor)
        }
    }

    private var acPopup: some View {
        Text("ac_help_popup".localized)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(hex: "8FE3E0"), in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
    }
}
