//
//  LocalizationManager.swift
//  Binbon
//
//  Created by Salah Khaled on 23/04/2026.
//

import Foundation

// MARK: - LocalizationManager (JSON)
/// Lightweight JSON-backed localization. Loads `en.json` / `ar.json` from the
/// app bundle and resolves keys against the language currently stored in `Storage`.
/// Falls back to the English value, then to the raw key, when a translation is missing.
final class LocalizationManager {

    static let shared = LocalizationManager()

    private var tables: [String: [String: String]] = [:]
    private let fallbackLanguage = Language.english.rawValue

    private init() {
        Language.allCases.forEach { load($0.rawValue) }
    }

    // MARK: - Loading
    private func load(_ code: String) {
        guard
            let url = Bundle.main.url(forResource: code, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let table = try? JSONDecoder().decode([String: String].self, from: data)
        else {
            print("🌐 [Localization] Missing or invalid table for language (\(code))")
            return
        }
        tables[code] = table
    }

    // MARK: - Lookup
    private var currentLanguage: String {
        Storage.shared.language
    }

    /// Returns the localized value for `key` in the current language,
    /// falling back to English, then to the key itself.
    func text(_ key: String) -> String {
        if let value = tables[currentLanguage]?[key] { return value }
        if let value = tables[fallbackLanguage]?[key] { return value }
        return key
    }
}
