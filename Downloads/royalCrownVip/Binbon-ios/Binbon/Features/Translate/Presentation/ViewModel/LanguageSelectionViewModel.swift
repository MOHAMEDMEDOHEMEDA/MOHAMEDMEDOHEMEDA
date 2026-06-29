//
//  LanguageSelectionViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 10/06/2026.
//

import SwiftUI
import Combine

// MARK: - State

/// Status of the language-catalog load that runs when the picker opens.
enum LanguageLoadState {
    case idle
    case loading
    case loaded
    case failed(APIError)
}

@MainActor
class LanguageSelectionViewModel: ObservableObject {

    // MARK: - Published
    @Published var selectedLanguages: [String] = ["English", "Arabic"]
    @Published var suggestedLanguages: [String] = []
    @Published var allLanguages: [String] = []
    @Published var state: LanguageLoadState = .idle

    // MARK: - Use cases
    private let getSuggestedLanguagesUseCase: GetSuggestedLanguagesUseCase
    private let getAllLanguagesUseCase: GetAllLanguagesUseCase

    init(
        getSuggestedLanguagesUseCase: GetSuggestedLanguagesUseCase,
        getAllLanguagesUseCase: GetAllLanguagesUseCase
    ) {
        self.getSuggestedLanguagesUseCase = getSuggestedLanguagesUseCase
        self.getAllLanguagesUseCase = getAllLanguagesUseCase
        load()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            getSuggestedLanguagesUseCase: container.makeGetSuggestedLanguagesUseCase(),
            getAllLanguagesUseCase: container.makeGetAllLanguagesUseCase()
        )
    }

    // MARK: - Loading
    func load() {
        Task {
            state = .loading
            do {
                suggestedLanguages = try await getSuggestedLanguagesUseCase.execute()
                allLanguages = try await getAllLanguagesUseCase.execute()
                state = .loaded
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    // MARK: - Selection
    func toggleLanguage(_ language: String) {
        if selectedLanguages.contains(language) {
            selectedLanguages.removeAll { $0 == language }
        } else {
            selectedLanguages.append(language)
        }
    }

    func isSelected(_ language: String) -> Bool {
        selectedLanguages.contains(language)
    }

    // MARK: - Helpers
    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
