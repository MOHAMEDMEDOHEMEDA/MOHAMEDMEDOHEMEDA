//
//  LiveCountryModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 15/06/2026.
//

import Foundation

// MARK: - LiveContinent
enum LiveContinent: String, CaseIterable, Hashable {
    case arabWorld
    case europe
    case asia
    case americas
    case africa
    case oceania

    var headerKey: String {
        switch self {
        case .arabWorld: AppStrings.liveCountrySectionArabWorld
        case .europe:    AppStrings.liveCountrySectionEurope
        case .asia:      AppStrings.liveCountrySectionAsia
        case .americas:  AppStrings.liveCountrySectionAmericas
        case .africa:    AppStrings.liveCountrySectionAfrica
        case .oceania:   AppStrings.liveCountrySectionOceania
        }
    }
}

// MARK: - LiveCountry
struct LiveCountry: Identifiable, Hashable {
    let id: String
    let flagImageName: String

    /// Localized country name, resolved on access so it follows the app language.
    var displayName: String { AppStrings.liveCountryName(id).localized }
}

// MARK: - Static dataset
enum LiveCountriesData {

    static let byContinent: [(LiveContinent, [LiveCountry])] = [
        (.arabWorld, build(arabWorld)),
        (.europe, build(europe)),
        (.asia, build(asia)),
        (.americas, build(americas)),
        (.africa, build(africa)),
        (.oceania, build(oceania))
    ]

    private static func build(_ ids: [String]) -> [LiveCountry] {
        ids.map { LiveCountry(id: $0, flagImageName: "flag_\($0)") }
    }

    // ISO codes per continent. Display names are localized via the
    // `live_country_<id>` keys in en.json / ar.json (see AppStrings.liveCountryName).
    private static let arabWorld = [
        "ps", "sy", "sa", "eg", "kw", "qa", "om", "ae", "iq", "bh",
        "jo", "lb", "ly", "dz", "ma", "tn", "so", "ye", "sd"
    ]

    private static let europe = [
        "de", "ch", "hu", "fr", "es", "be", "se", "it", "gr", "no",
        "pt", "bg", "at", "dk", "hr", "ie", "nl", "sk", "al", "ua",
        "ro", "pl", "md", "by", "lt", "ee", "mt", "lv", "cz", "ru"
    ]

    private static let asia = [
        "ph", "in", "id", "tr", "jp", "ir", "th", "cn", "pk", "uz",
        "vn", "mm", "tw", "my", "kh", "bd", "np", "la", "kz", "hk",
        "az", "sg", "tj", "kg", "am", "lk", "ge", "af", "mv", "bn",
        "tm", "cy", "mn", "mo"
    ]

    private static let americas = [
        "mx", "us", "ca", "uy", "co", "br", "ar", "ec", "cr", "pr",
        "jm", "ve", "pe", "cl", "hn", "do", "py", "sv", "bo", "pa",
        "gu", "gt", "ni", "ht", "bs", "tt"
    ]

    private static let africa = [
        "ug", "ao", "ke", "ng", "et", "za", "tg", "gh", "gm", "sn",
        "bf", "cm", "ne", "bj", "tz", "td", "sz", "ga", "mw", "re",
        "ml", "mu", "mz", "mg", "zm"
    ]

    private static let oceania = [
        "au", "fj", "to", "pf", "pg", "nz"
    ]
}
