//
//  VoiceCallPreferenceKeys.swift
//  Binbon
//

import SwiftUI

/// Bounds of the top-bar ⋯ button, used to anchor the single-call more-options popover.
struct VoiceCallMenuAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>?
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

/// Per-tile three-dots button frames (in the `voiceCallBody` coordinate space). The grid
/// publishes them; the parent uses them to position the flat more-buttons layer and to
/// anchor the participant menu.
struct TileButtonFrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}
