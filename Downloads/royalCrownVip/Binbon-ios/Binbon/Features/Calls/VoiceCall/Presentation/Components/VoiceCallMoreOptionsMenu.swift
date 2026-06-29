//
//  VoiceCallMoreOptionsMenu.swift
//  Binbon
//
//  Anchored popover below the in-call ⋯ button: mute / restrict toggles plus
//  block and report actions. Matches the Figma purple → coral gradient card.
//

import SwiftUI

struct VoiceCallMoreOptionsMenu: View {

    static let width: CGFloat = 160
    static let height: CGFloat = 141
    private static let rowHeight: CGFloat = height / 4

    let isSoundMuted: Bool
    let isRestricted: Bool
    let onToggleMute: () -> Void
    let onToggleRestrict: () -> Void
    let onBlock: () -> Void
    let onReport: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            toggleRow(
                icon: isSoundMuted ? "speaker.wave.2.fill" : "speaker.slash.fill",
                title: isSoundMuted ? "voice_call_unmute_sound" : "voice_call_mute_sound",
                action: onToggleMute
            )
            divider
            toggleRow(
                icon: isRestricted ? "person.fill" : "person.slash.fill",
                title: isRestricted ? "voice_call_unrestrict" : "voice_call_restrict",
                action: onToggleRestrict
            )
            divider
            actionRow(
                icon: "nosign",
                title: "block",
                action: onBlock
            )
            divider
            actionRow(
                icon: "exclamationmark.octagon.fill",
                title: "report",
                action: onReport
            )
        }
        .frame(width: Self.width, height: Self.height)
        .background(menuBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.28), radius: 10, y: 6)
    }

    private var menuBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(AppColor.verificationGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColor.voiceCallOptionsMenuBorder, lineWidth: 0.5)
            )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.22))
            .frame(height: 1)
            .padding(.horizontal, 12)
    }

    private func toggleRow(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            rowLabel(icon: icon, title: title.localized, isDestructive: false)
        }
        .buttonStyle(.plain)
    }

    private func actionRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            rowLabel(icon: icon, title: title.localized, isDestructive: true)
        }
        .buttonStyle(.plain)
    }

    /// Figma: label on the leading side, icon on the trailing side — mirrors
    /// correctly in both LTR and RTL.
    private func rowLabel(icon: String, title: String, isDestructive: Bool) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .layoutPriority(1)
            Spacer(minLength: 2)
            VoiceCallSystemIcon(
                systemName: icon,
                pointSize: 17,
                color: isDestructive
                    ? UIColor(red: 1, green: 59 / 255, blue: 48 / 255, alpha: 1)
                    : .white
            )
            .frame(width: 20, height: 20)
            .voiceCallDirectionFixed()
        }
        .foregroundStyle(isDestructive ? Color(hex: "FF3B30") : .white)
        .padding(.horizontal, 10)
        .frame(height: Self.rowHeight)
        .contentShape(Rectangle())
    }
}

#Preview {
    ZStack(alignment: .topTrailing) {
        Color.black.ignoresSafeArea()
        VoiceCallMoreOptionsMenu(
            isSoundMuted: false,
            isRestricted: false,
            onToggleMute: {},
            onToggleRestrict: {},
            onBlock: {},
            onReport: {}
        )
        .padding()
    }
}
