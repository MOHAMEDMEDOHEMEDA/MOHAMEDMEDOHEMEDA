//
//  LegalSettingsRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — legal settings boundary the use case depends on. Returns the
//  entity and throws `APIError`.
//

import Foundation

protocol LegalSettingsRepositoryProtocol {
    func fetchLegalSettings() async throws -> LegalContent
}
