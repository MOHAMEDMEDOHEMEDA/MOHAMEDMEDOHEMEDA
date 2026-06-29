//
//  NationalityCountrySheet.swift
//  Binbon
//

import SwiftUI

struct NationalityCountrySheet: View {

    let selected: Country?
    let onSelect: (Country) -> Void
    let onDismiss: () -> Void

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
        VStack(spacing: 14) {
            Text("select_nationality".localized)
                .font(.headline)
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.appText.opacity(0.6))
                TextField("search_countries".localized, text: $query)
                    .font(.subheadline)
                    .foregroundStyle(.appText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.appText.opacity(0.12))
            )

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(filtered) { country in
                        CountryRow(
                            country: country,
                            isSelected: selected?.key == country.key
                        ) {
                            onSelect(country)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .environment(\.layoutDirection, localizer.language.direction)
    }
}

#Preview {
    NationalityCountrySheet(selected: .default, onSelect: { _ in }, onDismiss: {})
}
