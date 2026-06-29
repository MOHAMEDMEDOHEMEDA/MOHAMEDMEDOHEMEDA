//
//  LiveRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `LiveRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class LiveRepositoryImpl: LiveRepositoryProtocol {

    private let remote: LiveRemoteDataSource

    init(remote: LiveRemoteDataSource) {
        self.remote = remote
    }

    func loadCategories() async throws -> [LiveCategory] {
        try await remote.loadCategories()
    }

    func loadHero() async throws -> GoLiveHeroModel {
        try await remote.loadHero()
    }

    func loadBroadcasts(category: LiveCategoryKind?) async throws -> [LiveBroadcast] {
        try await remote.loadBroadcasts(category: category)
    }

    func loadCountryBroadcasts(country: LiveCountry) async throws -> [LiveBroadcast] {
        try await remote.loadCountryBroadcasts(country: country)
    }

    func loadCountrySections() async throws -> [(LiveContinent, [LiveCountry])] {
        try await remote.loadCountrySections()
    }
}
