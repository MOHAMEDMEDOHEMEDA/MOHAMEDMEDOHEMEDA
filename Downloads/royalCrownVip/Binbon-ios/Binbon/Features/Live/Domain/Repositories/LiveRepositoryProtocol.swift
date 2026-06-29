//
//  LiveRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — boundary the Live use cases depend on. Returns reused app models
//  and throws `APIError`; the concrete implementation lives in Data.
//

import Foundation

protocol LiveRepositoryProtocol {
    /// Category chips shown on the Live landing screen.
    func loadCategories() async throws -> [LiveCategory]

    /// The "go live" hero shown above the broadcasts grid.
    func loadHero() async throws -> GoLiveHeroModel

    /// Broadcasts for a given category (nil = the Live landing feed).
    func loadBroadcasts(category: LiveCategoryKind?) async throws -> [LiveBroadcast]

    /// Broadcasts streaming from a given country.
    func loadCountryBroadcasts(country: LiveCountry) async throws -> [LiveBroadcast]

    /// Countries grouped by continent for the countries browser.
    func loadCountrySections() async throws -> [(LiveContinent, [LiveCountry])]
}
