//
//  LiveRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the Live feature. Mock-backed during the
//  current pre-integration phase.
//

import Foundation

protocol LiveRemoteDataSource {
    func loadCategories() async throws -> [LiveCategory]
    func loadHero() async throws -> GoLiveHeroModel
    func loadBroadcasts(category: LiveCategoryKind?) async throws -> [LiveBroadcast]
    func loadCountryBroadcasts(country: LiveCountry) async throws -> [LiveBroadcast]
    func loadCountrySections() async throws -> [(LiveContinent, [LiveCountry])]
}

// MARK: - Mock

struct MockLiveRemoteDataSource: LiveRemoteDataSource {

    func loadCategories() async throws -> [LiveCategory] {
        LiveCategoryKind.allCases.map { LiveCategory(id: $0.rawValue, kind: $0) }
    }

    func loadHero() async throws -> GoLiveHeroModel {
        .mock
    }

    func loadBroadcasts(category: LiveCategoryKind?) async throws -> [LiveBroadcast] {
        // Landing feed uses the artists/celebrities previews; a category feed uses
        // its own previews and prefixes ids so cells stay stable across switches.
        let kind = category ?? .artistsCelebrities
        let images = kind.previewImages
        let prefix = category?.rawValue ?? "live"
        return (0..<6).map { index in
            LiveBroadcast(
                id: "\(prefix)-\(index)",
                previewImageName: images[index % images.count],
                isHot: index % 3 == 0
            )
        }
    }

    func loadCountryBroadcasts(country: LiveCountry) async throws -> [LiveBroadcast] {
        let previews = ["woman", "man"]
        return (0..<8).map { index in
            LiveBroadcast(
                id: "\(country.id)-\(index)",
                previewImageName: previews[index % previews.count],
                isHot: index % 3 == 0
            )
        }
    }

    func loadCountrySections() async throws -> [(LiveContinent, [LiveCountry])] {
        LiveCountriesData.byContinent
    }
}

private extension GoLiveHeroModel {
    static let mock = GoLiveHeroModel(
        primaryUser: .init(
            id: "1",
            username: "user123_live",
            avatarImageName: "woman",
            previewImageName: "woman",
            badge: "❤️"
        ),
        secondaryUser: .init(
            id: "2",
            username: "beauty_queen_xo",
            avatarImageName: "man",
            previewImageName: "man",
            badge: "🥰"
        )
    )
}
