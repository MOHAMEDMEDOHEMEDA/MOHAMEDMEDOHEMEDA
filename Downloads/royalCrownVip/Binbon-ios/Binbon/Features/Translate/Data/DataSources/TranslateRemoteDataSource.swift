//
//  TranslateRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the language catalogs. Mock-backed during
//  the current pre-integration phase.
//

import Foundation

protocol TranslateRemoteDataSource {
    func getSuggestedLanguages() async throws -> [String]
    func getAllLanguages() async throws -> [String]
}

// MARK: - Mock

struct MockTranslateRemoteDataSource: TranslateRemoteDataSource {

    func getSuggestedLanguages() async throws -> [String] {
        [String].suggestedMock
    }

    func getAllLanguages() async throws -> [String] {
        [String].allLanguagesMock
    }
}

private extension Array where Element == String {

    static let suggestedMock = ["English", "Arabic"]

    static let allLanguagesMock = [
        "Bahasa Indonesia",
        "Bahasa Melayu",
        "Basa Jawa",
        "Català",
        "Cebuano",
        "Cestina",
        "Dansk",
        "Deutsch",
        "Eesti",
        "English",
        "Español",
        "Filipino",
        "Français",
        "Gaeilge",
        "Hrvatski",
        "Íslenska",
        "Italiano",
        "Kiswahili",
        "Latvieรับ",
        "Lietuviy",
        "Magyar",
        "Nederlands",
        "norsk (bokmäl)",
        "O'zbek",
        "Polski",
        "Português",
        "Română",
        "Shaip",
        "Suomi",
        "Svenska",
        "Tiếng Việt",
        "Türkçe",
        "ЕЛЛпІКа",
        "Български",
        "Казакша",
        "Русский",
        "Українська",
        "ภาวม",
        "اردو",
        "العربية",
        "ภาษาไทย",
        "日本語",
        "中文（繁體）",
        "中文（简体）",
        "한국어",
        "ภาษาไทย",
    ]
}
