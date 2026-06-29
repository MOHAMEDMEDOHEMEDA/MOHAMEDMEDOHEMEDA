//
//  CountryBroadcastsViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 15/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class CountryBroadcastsViewModel: ObservableObject {

    let country: LiveCountry

    @Published private(set) var broadcasts: [LiveBroadcast] = []

    let news = LiveNewsBanner(
        headlines: [
            "عبدالرحمن يهنّئ خالد بعيد ميلاده",
            "ريم تبارك"
        ],
        backgroundImageName: "celebrity_news_bg"
    )

    // MARK: - Use cases
    private let loadCountryBroadcastsUseCase: LoadCountryBroadcastsUseCase

    // MARK: - Init
    init(
        country: LiveCountry,
        loadCountryBroadcastsUseCase: LoadCountryBroadcastsUseCase
    ) {
        self.country = country
        self.loadCountryBroadcastsUseCase = loadCountryBroadcastsUseCase
        load()
    }

    convenience init(country: LiveCountry, container: AppDIContainer = .shared) {
        self.init(
            country: country,
            loadCountryBroadcastsUseCase: container.makeLoadCountryBroadcastsUseCase()
        )
    }

    // MARK: - Load
    private func load() {
        let country = country
        Task {
            broadcasts = (try? await loadCountryBroadcastsUseCase.execute(country: country)) ?? []
        }
    }
}
