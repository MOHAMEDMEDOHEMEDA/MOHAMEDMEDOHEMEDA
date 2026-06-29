//
//  Localizer+SwiftUI.swift
//  Binbon
//
//  Created by Salah Khaled on 23/04/2026.
//

import SwiftUI

// MARK: - Environment
private struct LocalizerKey: EnvironmentKey {
    static let defaultValue: Localizer = .shared
}

extension EnvironmentValues {
    var localizer: Localizer {
        get { self[LocalizerKey.self] }
        set { self[LocalizerKey.self] = newValue }
    }
}

// MARK: - Modifier
private struct LocalizerModifier: ViewModifier {
    @ObservedObject private var localizer = Localizer.shared

    func body(content: Content) -> some View {
        content
            .environment(\.localizer, localizer)
            .environment(\.layoutDirection, localizer.language.direction)
            .environment(\.locale, localizer.language.locale)
            .id(localizer.language.rawValue)
    }
}

extension View {
    /// Re-renders the view tree on language change and applies the matching
    /// layout direction and locale.
    func localizer() -> some View {
        modifier(LocalizerModifier())
    }
}

// MARK: - Modal layout direction
/// `.sheet` / `.fullScreenCover` content is hosted in a separate context that
/// does NOT inherit the root `.localizer()`'s layout direction, so modals fall
/// back to LTR even in Arabic. Re-apply the current language's direction +
/// locale on each presented root to keep modals RTL-aware.
private struct LocalizedLayoutModifier: ViewModifier {
    @ObservedObject private var localizer = Localizer.shared

    func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, localizer.language.direction)
            .environment(\.locale, localizer.language.locale)
    }
}

extension View {
    /// Re-applies the active language's layout direction + locale. Attach to
    /// the root of any `.sheet` / `.fullScreenCover` content so it honors RTL.
    func localizedLayout() -> some View {
        modifier(LocalizedLayoutModifier())
    }
}
