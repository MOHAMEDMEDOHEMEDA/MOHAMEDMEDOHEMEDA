//
//  Localizer.swift
//  Binbon
//
//  Created by Salah Khaled on 23/04/2026.
//

import SwiftUI
import Combine

// MARK: - Localizer
/// Controls the app's current language: persists the choice, swizzles the bundle
/// for `NSLocalizedString` lookups, and applies the matching semantic content
/// attribute. SwiftUI text uses `String.localized` (JSON) via `LocalizationManager`.
final class Localizer: ObservableObject {

    static let shared = Localizer()
    @Published private(set) var language: Language

    private init() {
        let language = Language(rawValue: Storage.shared.language) ?? .english
        self.language = language
        apply(language)
    }

    // MARK: - Methods
    func change(language: Language) {
        guard language != self.language else { return }
        self.language = language
        Storage.shared.language = language.rawValue
        apply(language)
    }

    func localize(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    // MARK: - Private
    private func apply(_ language: Language) {
        Bundle.setLanguage(language.rawValue)
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        UIView.appearance().semanticContentAttribute = language.direction == .rightToLeft ? .forceRightToLeft : .forceLeftToRight
    }
}
