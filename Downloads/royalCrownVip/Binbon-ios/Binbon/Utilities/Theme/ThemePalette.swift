//
//  ThemePalette.swift
//  Binbon
//
//  Created by Mrwan hany on 04/06/2026.
//
//

import SwiftUI

struct ThemePalette {

    // MARK: - Per-theme surfaces
    let gradientTop: Color
    let gradientBottom: Color
    let gradientStart: Color
    let gradientEnd: Color
    let cardBackground: Color
    let backgroundGradientTop: Color
    let backgroundGradientBottom: Color
    /// Surface behind expandable sections / notification cards.
    let sectionSurface: Color

    /// Fill used for the bottom tab bar (and the floating "+" button).
    /// Solid charcoal on Dark / Light, brand gradient on Colored.
    let tabBarFill: AnyShapeStyle

    /// Solid fill behind the Profile screen's top header. Blends with the
    /// app background on Dark / Light (black / light), purple on Colored.
    let profileHeaderColor: Color

    /// When set, every brand gradient (buttons, list rows, date panel…)
    /// collapses to this single flat color instead of its purple/coral
    /// stops. Dark theme uses it so the whole app shares the tab bar's
    /// charcoal; Light / Colored leave it `nil` to keep their gradients.
    let flatAccent: Color?

    // MARK: - Shared brand accents
    /// Gold accent. Kept only on the Colored theme; Light / Dark drop
    /// gold for neutral ink (`appText`) so nothing reads as gold there.
    /// (The bottom tab bar's active item hard-codes its own gold and is
    /// intentionally unaffected.)
    var gold: Color { flatAccent == nil ? Color(hex: "FBBC05") : Color.appText }

    /// Gold → orange accent gradient (selected profile tabs, outlines).
    /// Collapses to flat neutral ink off the Colored theme.
    var goldAccentGradient: LinearGradient {
        flatAccent == nil
        ? LinearGradient(colors: [Color(hex: "FBBC05"), Color(hex: "EB7048")],
                         startPoint: .top, endPoint: .bottom)
        : LinearGradient(colors: [Color.appText, Color.appText],
                         startPoint: .top, endPoint: .bottom)
    }

    var buttonBackground: Color { Color(hex: "D9536A").opacity(0.6) }
    var authListRowShadowColor: Color { Color.black.opacity(0.28) }
    var toggleOnColor: Color { .green }

    /// Builds a brand gradient, honoring `flatAccent`: when present the
    /// stops are replaced by the flat color so the gradient renders solid.
    private func brandGradient(_ colors: [Color],
                               _ start: UnitPoint,
                               _ end: UnitPoint) -> LinearGradient {
        let stops = flatAccent.map { [$0, $0] } ?? colors
        return LinearGradient(colors: stops, startPoint: start, endPoint: end)
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(colors: [gradientTop, gradientBottom], startPoint: .top, endPoint: .bottom)
    }
    var backgroundGradientApp: LinearGradient {
        LinearGradient(
            colors: [backgroundGradientTop, backgroundGradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// First auth list row (Account verification): same stops as background.
    var authListFirstRowGradient: LinearGradient { backgroundGradient }

    var buttonGradient: LinearGradient {
        brandGradient([Color(hex: "EB7048"), Color(hex: "83489C")], .top, .bottom)
    }
    
    var liveSubTabGradient: LinearGradient {
        brandGradient( [Color(hex: "83489C"), Color(hex: "7C0930")], .topLeading, .bottomTrailing)
    }

    /// Brand coral → purple gradient used as the tab bar fill on the
    /// Light / Colored themes.
    static let brandBarGradient = LinearGradient(
        colors: [Color(hex: "E14554"), Color(hex: "83489C")],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Following auth list rows: vertical coral → purple (pill bar).
    var authListFollowingRowGradient: LinearGradient {
        brandGradient([Color(hex: "8E448B"), Color(hex: "E67E5B")], .top, .bottom)
    }

    /// Bottom-sheet date/time picker card gradient.
    var datePickerPanelGradient: LinearGradient {
        brandGradient([Color(hex: "E86B4A"), Color(hex: "C94A6B"), Color(hex: "6B3A7E")], .top, .bottom)
    }
}

// MARK: - Concrete themes
extension ThemePalette {

    /// Today's vivid brand look — kept exactly as it was.
    static let colored = ThemePalette(
        gradientTop: Color(hex: "83489C"),
        gradientBottom: Color(hex: "7C0930"),
        gradientStart: Color(red: 0.95, green: 0.35, blue: 0.30),
        gradientEnd: Color(red: 0.55, green: 0.30, blue: 0.75),
        cardBackground: Color(hex: "C0485A").opacity(0.55),
        backgroundGradientTop: Color(hex: "964E8C"),
        backgroundGradientBottom: Color(hex: "E26B4E"),
        sectionSurface: Color.white.opacity(0.15),
        tabBarFill: AnyShapeStyle(ThemePalette.brandBarGradient),
        profileHeaderColor: Color(hex: "83418B"),
        flatAccent: nil
    )

    /// True light mode — white background, dark (`appText`) ink.
    /// Brand gradients flatten to the same charcoal as Dark so there's
    /// no purple in Light either.
    static let light = ThemePalette(
        gradientTop: Color(hex: "FFFFFF"),
        gradientBottom: Color(hex: "F3EFF7"),
        gradientStart: Color(red: 0.95, green: 0.35, blue: 0.30),
        gradientEnd: Color(red: 0.55, green: 0.30, blue: 0.75),
        cardBackground: Color(hex: "83489C").opacity(0.06),
        backgroundGradientTop: Color(hex: "FFFFFF"),
        backgroundGradientBottom: Color(hex: "F3EFF7"),
        sectionSurface: Color(hex: "171719").opacity(0.15),
        tabBarFill: AnyShapeStyle(Color(hex: "E5E5E5")),
        profileHeaderColor: Color(hex: "FFFFFF"),
        flatAccent: Color(hex: "2B2B2B")
    )

    /// Fully black surfaces; every brand gradient flattens to the same
    /// charcoal as the tab bar, header blends into the black background.
    static let dark = ThemePalette(
        gradientTop: Color(hex: "000000"),
        gradientBottom: Color(hex: "000000"),
        gradientStart: Color(red: 0.95, green: 0.35, blue: 0.30),
        gradientEnd: Color(red: 0.55, green: 0.30, blue: 0.75),
        cardBackground: Color(hex: "2B2B2B"),
        backgroundGradientTop: Color(hex: "000000"),
        backgroundGradientBottom: Color(hex: "000000"),
        sectionSurface: Color(hex: "2B2B2B"),
        tabBarFill: AnyShapeStyle(Color(hex: "2B2B2B")),
        profileHeaderColor: Color(hex: "000000"),
        flatAccent: Color(hex: "2B2B2B")
    )
}
