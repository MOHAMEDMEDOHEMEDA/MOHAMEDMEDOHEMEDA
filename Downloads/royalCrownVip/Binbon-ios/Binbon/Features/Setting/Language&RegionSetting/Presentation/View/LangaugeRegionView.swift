//
//  LangaugeRegionView.swift
//  Binbon
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 18/06/2026.

import SwiftUI

struct LangaugeRegionView: View {

    @StateObject private var viewModel = LanguageRegionViewModel()
    @State private var isNationalityCountryPickerOpen = false

     //MARK: - body
    var body: some View {
        ExpandView {
            Section("language_selection".localized) { languageSection }
            Section("country_region_setup".localized) { countryRegionSection }
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "language_region_settings".localized)
        .onAppear { viewModel.syncPrimaryLanguage() }
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomSaveBar }
        // for language sheet popUp
        .sheetView(
            isPresented: $viewModel.showLanguagePicker,
            detents: [.fraction(0.60), .medium],
            showsIndicator: true,
            cornerRadius: 20
        ) {
            LanguageSheet(
                current: viewModel.primaryLanguage,
                onSelect: viewModel.selectLanguage,
                onDismiss: { viewModel.showLanguagePicker = false }
            )
        }
        // for select region from map
        .fullScreenCover(isPresented: $viewModel.showLocationPicker) {
            MapLocationPickerView(
                onSelect: viewModel.selectLocation,
                onClose: { viewModel.showLocationPicker = false }
            )
        }
    }

    // MARK: - Language
    private var languageSection: some View {
        FormRow(label: "primary_language".localized, showsDivider: false) {
            Button { viewModel.showLanguagePicker = true } label: {
                Text(viewModel.primaryLanguage.localizedName)
                    .font(.subheadline)
                    .foregroundStyle(.appText)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Country / Region
    private var countryRegionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FormRow(label: "nationality".localized, showsDivider: false) {
                PhoneFieldWithDropdown(
                    dialCode: $viewModel.dialCode,
                    country: $viewModel.selectedCountry,
                    phoneNumber: $viewModel.nationality,
                    fieldStyle: .nationality,
                    placeholder: "nationality_placeholder".localized,
                    keyboard: .default,
                    onCountryPickerVisibilityChange: { isOpen in
                        isNationalityCountryPickerOpen = isOpen
                    }
                )
                .frame(maxWidth: 240)
            }
            .zIndex(isNationalityCountryPickerOpen ? 100 : 0)
            .onChange(of: viewModel.selectedCountry) { _, country in
                viewModel.dialCode = country.dialCode
                viewModel.nationality = Localizer.shared.language == .arabic ? country.nameAr : country.nameEn
            }

            FormRow(label: "region".localized, showsDivider: false) {
                RegionLocationField(
                    regionName: viewModel.regionName,
                    onChange: { viewModel.showLocationPicker = true }
                )
                .frame(maxWidth: 240)
            }

            FormRow(label: "postal_code".localized, showsDivider: false) {
                PostalCodeField(text: $viewModel.postalCode)
                    .frame(maxWidth: 240)
            }

            AppButton(
                title: "save".localized,
                isLoading: $viewModel.isLoading,
                action: viewModel.save
            )
            .padding(.top, 20)
        }
    }

    private var bottomSaveBar: some View {
        AppButton(
            title: "save_changes".localized,
            isLoading: $viewModel.isLoading,
            action: viewModel.save
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .adaptiveContentWidth()
        .background(.ultraThinMaterial.opacity(0.01))
    }
}


#Preview {
    NavigationStack {
        LangaugeRegionView()
    }
}
