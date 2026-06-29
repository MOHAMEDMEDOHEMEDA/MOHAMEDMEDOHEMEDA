//
//  ContentPrivacySettingView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 03/06/2026.
//

import SwiftUI

struct ContentPrivacySettingView: View {

    @StateObject var viewModel = ContentPrivacySettingViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
            Section("preferred_content_type".localized) { preferredContentSection }
            Section("content_age_rating".localized) { ageRatingSection }
            Section("kids_mode".localized) { kidsModeSection }
            Section("block_offensive_words".localized) { blockedWordsSection }
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "content_digital_privacy_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchSettings() }
    }

    private var saveButton: some View {
        Button { viewModel.save() } label: {
            Text("save_changes".localized)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.buttonGradient))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDataNoChanges())
    }

    // MARK: - Preferred content type
    private var preferredContentSection: some View {
        FlowLayout(spacing: 10, lineSpacing: 12) {
            ForEach(viewModel.visibleCategories) { category in
                categoryChip(category)
            }

            if viewModel.hasMoreCategories && !viewModel.showAllCategories {
                Button {
                    withAnimation { viewModel.showAllCategories = true }
                } label: {
                    Text("more".localized)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.appGold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func categoryChip(_ category: ContentCategory) -> some View {
        let selected = viewModel.isSelected(category)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { viewModel.toggle(category) }
        } label: {
            Text(category.name)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.appText)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .fill(selected ? AnyShapeStyle(AppColor.chromeButtonGradient) : AnyShapeStyle(Color.clear))
                )
                .overlay(
                    Capsule()
                        .stroke(selected ? Color.appGold : Color.appGold.opacity(0.45),
                                lineWidth: selected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Age rating
    private var ageRatingSection: some View {
        Button {
            withAnimation { viewModel.isUnderAge.toggle() }
        } label: {
            HStack(alignment: .center, spacing: 16) {
                Text("under_18_prompt".localized)
                    .font(.footnote)
                    .foregroundStyle(.appText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 8) {
                    Text("under_18".localized)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.appText)

                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.appText.opacity(0.7), lineWidth: 1.5)
                            .frame(width: 22, height: 22)

                        if viewModel.isUnderAge {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.appGold)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Kids mode
    private var kidsModeSection: some View {
        Toggle(isOn: $viewModel.kidsModeEnabled) {
            Text("kids_mode_prompt".localized)
                .font(.footnote)
                .foregroundStyle(.appText)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Blocked words
    private var blockedWordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("block_words_description".localized)
                .font(.footnote)
                .foregroundStyle(.appText)

            MultilineTextField(
                text: $viewModel.blockedWords,
                placeholder: "block_words_placeholder".localized
            )
        }
    }
}

#Preview {
    NavigationView {
        ContentPrivacySettingView()
    }
}
