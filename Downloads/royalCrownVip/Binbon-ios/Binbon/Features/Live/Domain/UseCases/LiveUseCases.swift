//
//  LiveUseCases.swift
//  Binbon
//
//  Domain layer — one use case per Live data operation.
//

import Foundation

struct LoadLiveCategoriesUseCase {
    private let repository: LiveRepositoryProtocol

    init(repository: LiveRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [LiveCategory] {
        try await repository.loadCategories()
    }
}

struct LoadLiveHeroUseCase {
    private let repository: LiveRepositoryProtocol

    init(repository: LiveRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> GoLiveHeroModel {
        try await repository.loadHero()
    }
}

struct LoadBroadcastsUseCase {
    private let repository: LiveRepositoryProtocol

    init(repository: LiveRepositoryProtocol) {
        self.repository = repository
    }

    func execute(category: LiveCategoryKind? = nil) async throws -> [LiveBroadcast] {
        try await repository.loadBroadcasts(category: category)
    }
}

struct LoadCountryBroadcastsUseCase {
    private let repository: LiveRepositoryProtocol

    init(repository: LiveRepositoryProtocol) {
        self.repository = repository
    }

    func execute(country: LiveCountry) async throws -> [LiveBroadcast] {
        try await repository.loadCountryBroadcasts(country: country)
    }
}

struct LoadLiveCountrySectionsUseCase {
    private let repository: LiveRepositoryProtocol

    init(repository: LiveRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [(LiveContinent, [LiveCountry])] {
        try await repository.loadCountrySections()
    }
}
