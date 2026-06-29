//
//   LiveViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 11/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class LiveViewModel: ObservableObject {

    // MARK: - Published
    @Published var selectedSubTab: LiveSubTab = .broadcasts
    @Published private(set) var categories: [LiveCategory] = []
    @Published private(set) var hero: GoLiveHeroModel?
    @Published private(set) var broadcasts: [LiveBroadcast] = []

    // MARK: - Use cases
    private let loadCategoriesUseCase: LoadLiveCategoriesUseCase
    private let loadHeroUseCase: LoadLiveHeroUseCase
    private let loadBroadcastsUseCase: LoadBroadcastsUseCase

    // MARK: - Init
    init(
        loadCategoriesUseCase: LoadLiveCategoriesUseCase,
        loadHeroUseCase: LoadLiveHeroUseCase,
        loadBroadcastsUseCase: LoadBroadcastsUseCase
    ) {
        self.loadCategoriesUseCase = loadCategoriesUseCase
        self.loadHeroUseCase = loadHeroUseCase
        self.loadBroadcastsUseCase = loadBroadcastsUseCase
        load()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            loadCategoriesUseCase: container.makeLoadLiveCategoriesUseCase(),
            loadHeroUseCase: container.makeLoadLiveHeroUseCase(),
            loadBroadcastsUseCase: container.makeLoadBroadcastsUseCase()
        )
    }

    // MARK: - Load
    private func load() {
        Task {
            categories = (try? await loadCategoriesUseCase.execute()) ?? []
            hero = try? await loadHeroUseCase.execute()
            broadcasts = (try? await loadBroadcastsUseCase.execute()) ?? []
        }
    }
}
