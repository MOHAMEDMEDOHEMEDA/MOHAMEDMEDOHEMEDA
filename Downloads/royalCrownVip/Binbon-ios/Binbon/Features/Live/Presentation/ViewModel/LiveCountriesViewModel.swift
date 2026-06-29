//
//  LiveCountriesViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 15/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class LiveCountriesViewModel: ObservableObject {

    @Published private(set) var sections: [(LiveContinent, [LiveCountry])] = []

    private let loadCountrySectionsUseCase: LoadLiveCountrySectionsUseCase

    init(loadCountrySectionsUseCase: LoadLiveCountrySectionsUseCase) {
        self.loadCountrySectionsUseCase = loadCountrySectionsUseCase
        load()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(loadCountrySectionsUseCase: container.makeLoadLiveCountrySectionsUseCase())
    }

    func select(_ country: LiveCountry) {
        // TODO: navigate to broadcasts filtered by country.id
    }

    private func load() {
        Task {
            sections = (try? await loadCountrySectionsUseCase.execute()) ?? []
        }
    }
}
