//
//  Bundle+Language.swift
//  Binbon
//
//  Created by Salah Khaled on 23/04/2026.
//

import Foundation

// MARK: - Language Bundle
private var bundleKey: UInt8 = 0

/// A `Bundle` subclass that redirects `.strings` lookups to the `.lproj` of the
/// currently selected language, enabling runtime language switching for
/// `NSLocalizedString`-based strings.
fileprivate final class LanguageBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    /// Swizzles `Bundle.main` to resolve strings from the given language's `.lproj`.
    static func setLanguage(_ language: String) {
        object_setClass(Bundle.main, LanguageBundle.self)

        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            objc_setAssociatedObject(Bundle.main, &bundleKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
