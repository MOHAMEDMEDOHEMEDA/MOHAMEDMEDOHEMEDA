//
//  VoiceCallTopBar.swift
//  Binbon
//

import SwiftUI

/// Top chrome of the voice call: owner menu + add-person on the leading side, the
/// call duration in the middle (group calls only), and more-options + minimize trailing.
/// The ⋯ button publishes its bounds via `VoiceCallMenuAnchorKey` so the parent can
/// anchor the one-to-one more-options popover.
struct VoiceCallTopBar: View {

    let isGroupCall: Bool
    let durationText: String
    let onMenu: () -> Void
    let onAddPerson: () -> Void
    let onMore: () -> Void
    let onMinimize: () -> Void

    private let iconSize: CGFloat = 25
    private let tapSize: CGFloat = 35

    var body: some View {
        HStack(spacing: 22) {
            HStack(spacing: 22) {
                button(icon: "calls-menu", accessibilityKey: "voice_call_menu", action: onMenu)
                button(icon: "calls-addperson", accessibilityKey: "voice_call_add_person", action: onAddPerson)
            }

            Spacer(minLength: 0)

            if isGroupCall {
                Text(durationText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 0)

            HStack(spacing: 22) {
                if !isGroupCall {
                    moreOptionsButton
                }
                button(icon: "calls-chevdown", accessibilityKey: "voice_call_minimize", action: onMinimize)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        // Keep chrome in a fixed LTR order so ⋯ stays trailing in every locale
        // (matches Figma) and the options popover anchor stays consistent.
        .environment(\.layoutDirection, .leftToRight)
    }

    private var moreOptionsButton: some View {
        Button(action: onMore) {
            icon("calls-3dots")
                .anchorPreference(key: VoiceCallMenuAnchorKey.self, value: .bounds) { $0 }
                .frame(width: tapSize, height: tapSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("voice_call_more_options".localized)
    }

    private func button(icon name: String, accessibilityKey: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon(name)
                .frame(width: tapSize, height: tapSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityKey.localized)
    }

    private func icon(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: iconSize, height: iconSize)
    }
}
