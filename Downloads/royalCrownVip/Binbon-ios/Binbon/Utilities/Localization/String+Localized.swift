//
//  String+Localized.swift
//  Binbon
//
//  Created by Salah Khaled on 23/04/2026.
//

import Foundation

// MARK: - String (JSON localization)
extension String {

    /// JSON-backed localized value for this key. Returns the key itself when missing.
    var localized: String {
        LocalizationManager.shared.text(self)
    }

    /// Localized value formatted with the given arguments, preserving placeholders (%@, %d, %f).
    func localizedFormat(_ args: CVarArg...) -> String {
        String(format: LocalizationManager.shared.text(self), arguments: args)
    }
}

// MARK: - String (NSLocalizedString / .strings)
extension String {

    var localize: String {
        Localizer.shared.localize(self)
    }

    func localize(with args: CVarArg...) -> String {
        String(format: Localizer.shared.localize(self), arguments: args)
    }
}
