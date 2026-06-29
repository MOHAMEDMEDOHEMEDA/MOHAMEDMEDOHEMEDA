//
//  LanguageRegionViewModel.swift
//  Binbon
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓼𝓲𝓮𝓷 on 18/06/2026.


import SwiftUI
import Combine

@MainActor
final class LanguageRegionViewModel: ObservableObject {

    @Published var primaryLanguage: Language
    @Published var selectedCountry: Country = .default
    @Published var dialCode: String = Country.default.dialCode
    @Published var nationality = ""
    @Published var regionName: String?
    @Published var postalCode = ""
    @Published var isLoading = false
    @Published var showLanguagePicker = false
    @Published var showLocationPicker = false

    init() {
        let user = Storage.shared.user
        primaryLanguage = Localizer.shared.language

        if let countryName = user?.country,
           let country = Country.all.first(where: {
               $0.nameEn.caseInsensitiveCompare(countryName) == .orderedSame || $0.nameAr == countryName
           }) {
            selectedCountry = country
            dialCode = country.dialCode
            nationality = countryName
        } else {
            selectedCountry = .default
            dialCode = Country.default.dialCode
            nationality = user?.country ?? ""
        }

        regionName = user?.regionName
        postalCode = user?.postalCode ?? ""
    }

    func selectLanguage(_ language: Language) {
        primaryLanguage = language
        Localizer.shared.change(language: language)
        showLanguagePicker = false
    }

    func syncPrimaryLanguage() {
        primaryLanguage = Localizer.shared.language
    }

    func selectLocation(_ place: PlaceItem) {
        regionName = place.name
        showLocationPicker = false
    }

    func save() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            isLoading = false
            Toaster.shared.show(.success(), "update_successfully".localized)
        }
    }
}
