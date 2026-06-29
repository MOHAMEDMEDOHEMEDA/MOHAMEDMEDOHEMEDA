//
//  ParticipantActionMenu.swift
//  Binbon
//  Created by Mahmoud Elsharkawy on 23/06/2026.
//

import SwiftUI

enum ParticipantMenuAction {
    case toggleVideo
    case toggleMute
    case restrict
    case block
    case report
}

struct ParticipantActionMenu: View {

    let isVideoOff: Bool
    let isMuted: Bool
    let onAction: (ParticipantMenuAction) -> Void

    var body: some View {
        VStack(spacing: 0) {
            row(
                titleKey: isVideoOff ? "voice_call_action_open_video" : "voice_call_action_close_video",
                systemImage: isVideoOff ? "video.fill" : "video.slash.fill",
                action: .toggleVideo
            )
            divider
            row(
                titleKey: isMuted ? "voice_call_action_unmute" : "voice_call_action_mute",
                systemImage: isMuted ? "speaker.wave.2.fill" : "speaker.slash.fill",
                action: .toggleMute
            )
            divider
            row(
                titleKey: "voice_call_action_restrict",
                systemImage: "person.fill.xmark",
                action: .restrict
            )
            divider
            row(
                titleKey: "voice_call_action_block",
                systemImage: "nosign",
                action: .block,
                isDestructive: true
            )
            divider
            row(
                titleKey: "voice_call_action_report",
                systemImage: "exclamationmark.circle",
                action: .report,
                isDestructive: true
            )
        }
        .frame(width: 210)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColor.backgroundGradient)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
    }

    private func row(
        titleKey: String,
        systemImage: String,
        action: ParticipantMenuAction,
        isDestructive: Bool = false
    ) -> some View {
        Button {
            onAction(action)
        } label: {
            HStack(spacing: 10) {
                Text(titleKey.localized)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 22)
            }
            .foregroundStyle(isDestructive ? AppColor.destructive : .appText)
            .padding(.horizontal, 14)
            .frame(height: 46)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.appText.opacity(0.18))
            .frame(height: 1)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ParticipantActionMenu(isVideoOff: false, isMuted: false) { _ in }
    }
}
