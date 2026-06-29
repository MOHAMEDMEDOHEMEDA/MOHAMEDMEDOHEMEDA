//
//  FetchLegalSettingsUseCase.swift
//  Binbon
//
//  Domain layer — loads the legal documents (terms, privacy, …).
//

import Foundation

struct FetchLegalSettingsUseCase {
    private let repository: LegalSettingsRepositoryProtocol

    init(repository: LegalSettingsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> LegalContent {
        try await repository.fetchLegalSettings()
    }
}
