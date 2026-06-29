//
//  ThemeManager.swift
//  Binbon
//
//  Created by Mrwan hany on 04/06/2026.
//
//  App-wide theme state. Drives `AppColor` and the root `.theme()`
//  modifier so changing the switch in Theme settings repaints the
//  whole app live and persists the choice.
//

import SwiftUI
import UIKit
import Combine

final class ThemeManager: ObservableObject {

    static let shared = ThemeManager()

    @Published var mode: AppThemeMode {
        didSet { Storage.shared.theme = mode.rawValue }
    }

    /// Live device color scheme, pushed in from the root `.theme()`
    /// modifier. Publishing it here makes `.system` mode repaint the
    /// whole app the instant the system appearance flips — no tab
    /// switch needed to force a redraw.
    @Published var systemScheme: ColorScheme

    private init() {
        mode = AppThemeMode(rawValue: Storage.shared.theme) ?? .system
        systemScheme = UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
    }

    /// Palette resolved against a specific environment color scheme
    /// (needed so `.system` follows the device live).
    func palette(for scheme: ColorScheme) -> ThemePalette {
        switch mode {
        case .light:   .light
        case .dark:    .dark
        case .system:  scheme == .dark ? .dark : .light
        case .colored: .colored
     
        }
    }

    /// Palette for non-SwiftUI / static call sites (e.g. `AppColor`).
    /// `.system` resolves against the published `systemScheme`, so any
    /// view reading `AppColor` repaints when the device appearance flips.
    var palette: ThemePalette {
        switch mode {
        case .light:   .light
        case .dark:    .dark
        case .system:  systemScheme == .dark ? .dark : .light
        case .colored: .colored
        }
    }

    /// Drives the SwiftUI color scheme so adaptive ink (`Color.appText`)
    /// and system surfaces (sheets, alerts, keyboards) match the theme.
    /// Colored keeps a dark scheme so its ink stays white over the
    /// vivid brand background.
    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .light:    .light
        case .dark:     .dark
        case .colored:  .dark
        case .system:   nil
        }
    }

    func select(_ newMode: AppThemeMode) {
        guard mode != newMode else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            mode = newMode
        }
    }
}
