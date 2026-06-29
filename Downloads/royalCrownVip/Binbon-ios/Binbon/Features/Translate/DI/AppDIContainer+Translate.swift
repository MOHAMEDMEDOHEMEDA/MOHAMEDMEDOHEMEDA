//
//  AppDIContainer+Translate.swift
//  Binbon
//
//  Composition root — Translate feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeTranslateRemoteDataSource() -> TranslateRemoteDataSource {
        MockTranslateRemoteDataSource()
    }

    func makeTranslateRepository() -> TranslateRepositoryProtocol {
        TranslateRepositoryImpl(remote: makeTranslateRemoteDataSource())
    }

    // MARK: - Use cases

    func makeGetSuggestedLanguagesUseCase() -> GetSuggestedLanguagesUseCase {
        GetSuggestedLanguagesUseCase(repository: makeTranslateRepository())
    }

    func makeGetAllLanguagesUseCase() -> GetAllLanguagesUseCase {
        GetAllLanguagesUseCase(repository: makeTranslateRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeLanguageSelectionViewModel() -> LanguageSelectionViewModel {
        LanguageSelectionViewModel(
            getSuggestedLanguagesUseCase: makeGetSuggestedLanguagesUseCase(),
            getAllLanguagesUseCase: makeGetAllLanguagesUseCase()
        )
    }
}
