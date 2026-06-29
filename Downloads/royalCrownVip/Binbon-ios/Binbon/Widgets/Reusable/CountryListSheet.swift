//
//  CountryListSheet.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// A reusable searchable country-selection sheet built from `Country.all` and
/// the existing `CountryRow`. Binds the chosen `Country` and dismisses on pick.
struct CountryListSheet: View {

    @Binding var country: Country?
    var onPick: ((Country) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var localizer = Localizer.shared
    @State private var query = ""

    private var filtered: [Country] {
        guard !query.isEmpty else { return Country.all }
        return Country.all.filter {
            $0.nameEn.localizedCaseInsensitiveContains(query) ||
            $0.nameAr.localizedCaseInsensitiveContains(query) ||
            $0.dialCode.contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(filtered) { item in
                        CountryRow(country: item, isSelected: country?.key == item.key) {
                            country = item
                            onPick?(item)
                            dismiss()
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
    CountryListSheet(country: .constant(.default))
}
