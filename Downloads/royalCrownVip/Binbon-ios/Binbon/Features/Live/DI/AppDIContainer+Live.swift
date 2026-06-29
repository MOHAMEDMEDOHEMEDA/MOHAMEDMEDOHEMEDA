//
//  AppDIContainer+Live.swift
//  Binbon
//
//  Composition root — Live feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeLiveRemoteDataSource() -> LiveRemoteDataSource {
        MockLiveRemoteDataSource()
    }

    func makeLiveRepository() -> LiveRepositoryProtocol {
        LiveRepositoryImpl(remote: makeLiveRemoteDataSource())
    }

    // MARK: - Use cases

    func makeLoadLiveCategoriesUseCase() -> LoadLiveCategoriesUseCase {
        LoadLiveCategoriesUseCase(repository: makeLiveRepository())
    }

    func makeLoadLiveHeroUseCase() -> LoadLiveHeroUseCase {
        LoadLiveHeroUseCase(repository: makeLiveRepository())
    }

    func makeLoadBroadcastsUseCase() -> LoadBroadcastsUseCase {
        LoadBroadcastsUseCase(repository: makeLiveRepository())
    }

    func makeLoadCountryBroadcastsUseCase() -> LoadCountryBroadcastsUseCase {
        LoadCountryBroadcastsUseCase(repository: makeLiveRepository())
    }

    func makeLoadLiveCountrySectionsUseCase() -> LoadLiveCountrySectionsUseCase {
        LoadLiveCountrySectionsUseCase(repository: makeLiveRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeLiveViewModel() -> LiveViewModel {
        LiveViewModel(
            loadCategoriesUseCase: makeLoadLiveCategoriesUseCase(),
            loadHeroUseCase: makeLoadLiveHeroUseCase(),
            loadBroadcastsUseCase: makeLoadBroadcastsUseCase()
        )
    }

    @MainActor
    func makeBroadcastsListViewModel(initialCategory: LiveCategoryKind) -> BroadcastsListViewModel {
        BroadcastsListViewModel(
            initialCategory: initialCategory,
            loadBroadcastsUseCase: makeLoadBroadcastsUseCase()
        )
    }

    @MainActor
    func makeCountryBroadcastsViewModel(country: LiveCountry) -> CountryBroadcastsViewModel {
        CountryBroadcastsViewModel(
            country: country,
            loadCountryBroadcastsUseCase: makeLoadCountryBroadcastsUseCase()
        )
    }

    @MainActor
    func makeLiveCountriesViewModel() -> LiveCountriesViewModel {
        LiveCountriesViewModel(loadCountrySectionsUseCase: makeLoadLiveCountrySectionsUseCase())
    }
}
