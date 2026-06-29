//
//  BroadcastsListViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 14/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class BroadcastsListViewModel: ObservableObject {

    // MARK: - Published
    @Published var selectedCategory: LiveCategoryKind
    @Published private(set) var broadcasts: [LiveBroadcast] = []

    // MARK: - Static config
    let categories = LiveCategoryKind.allCases
    let news = LiveNewsBanner(
        headlines: [
            "عبدالرحمن يهنّئ خالد بعيد ميلاده",
            "ريم تبارك"
        ],
        backgroundImageName: "celebrity_news_bg"
    )

    // MARK: - Use cases
    private let loadBroadcastsUseCase: LoadBroadcastsUseCase

    // MARK: - Init
    init(
        initialCategory: LiveCategoryKind,
        loadBroadcastsUseCase: LoadBroadcastsUseCase
    ) {
        selectedCategory = initialCategory
        self.loadBroadcastsUseCase = loadBroadcastsUseCase
        load()
    }

    convenience init(initialCategory: LiveCategoryKind, container: AppDIContainer = .shared) {
        self.init(
            initialCategory: initialCategory,
            loadBroadcastsUseCase: container.makeLoadBroadcastsUseCase()
        )
    }

    // MARK: - Intent
    func select(_ category: LiveCategoryKind) {
        guard category != selectedCategory else { return }
        selectedCategory = category
        load()
    }

    // MARK: - Load
    private func load() {
        let category = selectedCategory
        Task {
            broadcasts = (try? await loadBroadcastsUseCase.execute(category: category)) ?? []
        }
    }
}
