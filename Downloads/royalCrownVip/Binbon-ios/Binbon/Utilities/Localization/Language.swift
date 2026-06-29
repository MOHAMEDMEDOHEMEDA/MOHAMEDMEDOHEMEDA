//
//  Language.swift
//  Binbon
//
//  Created by Salah Khaled on 23/04/2026.
//

import SwiftUI

// MARK: - Language
enum Language: String, CaseIterable {
    case english = "en"
    case arabic  = "ar"

    var locale: Locale { Locale(identifier: rawValue) }

    var title: String {
        switch self {
        case .english: "English"
        case .arabic: "العربية"
        }
    }

    /// Native name of the language (does not change with app locale).
    var nativeName: String { title }

    /// Name shown in settings — follows the active app language.
    var localizedName: String {
        switch self {
        case .english: "lang_english".localized
        case .arabic: "lang_arabic".localized
        }
    }

    /// English name of the language (shown as a secondary label).
    var englishName: String {
        switch self {
        case .english: "English"
        case .arabic: "Arabic"
        }
    }

    /// Flag emoji representing the language.
    var flag: String {
        switch self {
        case .english: "🇬🇧"
        case .arabic: "🇸🇦"
        }
    }

    var direction: LayoutDirection {
        switch self {
        case .english: .leftToRight
        case .arabic: .rightToLeft
        }
    }
}
