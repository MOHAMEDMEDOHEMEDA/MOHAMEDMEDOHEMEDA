//
//  Responsive.swift
//  Binbon
//
//  Shared primitives for making the (375pt-baseline) UI adapt across device
//  sizes: full-width and scrollable on small phones so nothing clips, and capped
//  to a centered readable column on large regular-width screens (iPad) so the
//  phone layout doesn't stretch edge to edge.
//

import SwiftUI

enum Device {
    static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
}


private struct AdaptiveContentWidth: ViewModifier {
    var maxWidth: CGFloat
    @Environment(\.horizontalSizeClass) private var hSizeClass

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: hSizeClass == .regular ? maxWidth : .infinity)
            .frame(maxWidth: .infinity) // center the capped column in its container
    }
}

extension View {
    /// Centers and caps width on large (regular) screens; full-width on phones.
    func adaptiveContentWidth(_ maxWidth: CGFloat = 640) -> some View {
        modifier(AdaptiveContentWidth(maxWidth: maxWidth))
    }
}

// MARK: - Proportional size scale

private struct SizeScaleKey: EnvironmentKey { static let defaultValue: CGFloat = 1 }

extension EnvironmentValues {
    /// Proportional UI scale relative to the 375pt design baseline (1.0 = baseline).
    /// A screen sets it from its available width; child views multiply their fixed
    /// metrics by it so the whole layout grows/shrinks together across devices.
    var sizeScale: CGFloat {
        get { self[SizeScaleKey.self] }
        set { self[SizeScaleKey.self] = newValue }
    }
}

