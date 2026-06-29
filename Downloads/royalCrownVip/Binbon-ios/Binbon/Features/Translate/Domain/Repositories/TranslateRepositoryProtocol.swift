//
//  TranslateRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — translation/language boundary the use cases depend on. Returns
//  the language catalogs and throws `APIError`; the concrete implementation lives
//  in Data.
//

import Foundation

protocol TranslateRepositoryProtocol {
    /// Languages surfaced as quick suggestions at the top of the picker.
    func getSuggestedLanguages() async throws -> [String]

    /// The full language catalog the user can pick from.
    func getAllLanguages() async throws -> [String]
}
