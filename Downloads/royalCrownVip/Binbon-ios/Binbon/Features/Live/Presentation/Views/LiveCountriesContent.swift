//
//  LiveCountriesContent.swift
//  Binbon
//
//  Created by Aya Mashaly on 15/06/2026.
//

import SwiftUI

struct LiveCountriesContent: View {

    @Environment(\.router) private var router
    @StateObject private var viewModel = LiveCountriesViewModel()

    private let gridColumns = Array(
        repeating: GridItem(.flexible(), spacing: 9, alignment: .top),
        count: 4
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            ForEach(viewModel.sections, id: \.0) { continent, countries in
                section(continent, countries)
            }
        }
    }

    @ViewBuilder
    private func section(_ continent: LiveContinent, _ countries: [LiveCountry]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(continent.headerKey.localized)
                .font(.system(size: 15, weight: .medium))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppColor.sectionSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(AppColor.gold, lineWidth: 2)
                )

            LazyVGrid(columns: gridColumns, spacing: 9) {
                ForEach(countries) { country in
                    Button {
                        router.navigate(.liveCountryBroadcasts(country))
                    } label: {
                        CountryTile(country: country)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(country.displayName)
                }
            }
        }
    }
}
