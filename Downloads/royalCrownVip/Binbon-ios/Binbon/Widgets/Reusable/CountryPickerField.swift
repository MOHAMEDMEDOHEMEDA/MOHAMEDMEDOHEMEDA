//
//  CountryPickerField.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// A standalone country selector field: a `DisclosureFieldRow` showing the
/// chosen country (flag + localized name) that presents a searchable sheet of
/// `CountryRow`s built from `Country.all`. Reuses the existing `Country` model
/// and `CountryRow` widget. Wrap in `LabeledField` for a title.
struct CountryPickerField: View {

    @Binding var country: Country?
    var placeholder: String = "select_country".localized

    @ObservedObject private var localizer = Localizer.shared
    @State private var showPicker = false
    @State private var query = ""

    private var displayName: String? {
        guard let country else { return nil }
        return localizer.language == .arabic ? country.nameAr : country.nameEn
    }

    private var filtered: [Country] {
        guard !query.isEmpty else { return Country.all }
        return Country.all.filter {
            $0.nameEn.localizedCaseInsensitiveContains(query) ||
            $0.nameAr.localizedCaseInsensitiveContains(query) ||
            $0.dialCode.contains(query)
        }
    }

    var body: some View {
        DisclosureFieldRow(
            value: displayName,
            placeholder: placeholder,
            leadingFlag: country?.flag
        ) { showPicker = true }
        .sheet(isPresented: $showPicker) {
            pickerSheet
        }
    }

    private var pickerSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(filtered) { item in
                        CountryRow(country: item, isSelected: country?.key == item.key) {
                            country = item
                            showPicker = false
                        }
                    }
                }
                .padding(16)
            }
            .appBackground()
            .appNavigation(title: "anchor_country".localized)
            .searchable(text: $query)
        }
    }
}

#Preview {
    CountryPickerField(country: .constant(.default))
        .padding()
        .background(Color.black)
}
