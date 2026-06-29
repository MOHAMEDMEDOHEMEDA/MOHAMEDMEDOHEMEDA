//
//  TranslateUseCases.swift
//  Binbon
//
//  Domain layer — language-catalog operations for the translation settings flow.
//

import Foundation

struct GetSuggestedLanguagesUseCase {
    private let repository: TranslateRepositoryProtocol

    init(repository: TranslateRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [String] {
        try await repository.getSuggestedLanguages()
    }
}

struct GetAllLanguagesUseCase {
    private let repository: TranslateRepositoryProtocol

    init(repository: TranslateRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [String] {
        try await repository.getAllLanguages()
    }
}
