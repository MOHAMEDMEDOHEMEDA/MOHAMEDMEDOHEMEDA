//
//  VideoCallTopChrome.swift
//  Binbon
//

import SwiftUI

/// Top chrome of the video call: owner menu + add-person leading, the call duration
/// centered, and more-options (one-to-one only) + minimize trailing.
struct VideoCallTopChrome: View {

    let durationText: String
    let isGroupCall: Bool
    let onMenu: () -> Void
    let onAddPerson: () -> Void
    let onMore: () -> Void
    let onMinimize: () -> Void

    private let iconSize: CGFloat = 28
    private let tapSize: CGFloat = 44

    var body: some View {
        HStack {
            HStack(spacing: 22) {
                button(icon: "calls-menu", accessibilityKey: "voice_call_menu", action: onMenu)
                button(icon: "calls-addperson", accessibilityKey: "voice_call_add_person", action: onAddPerson)
            }
            Spacer(minLength: 0)
            HStack(spacing: 22) {
                if !isGroupCall {
                    button(icon: "calls-3dots", accessibilityKey: "voice_call_more_options", action: onMore)
                }
                button(icon: "calls-chevdown", accessibilityKey: "voice_call_minimize", action: onMinimize)
            }
        }
        .padding(.horizontal, 18)
        .overlay(alignment: .center) {
            Text(durationText)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 2, y: 2)
                .accessibilityLabel("voice_call_timer".localized)
        }
        .padding(.vertical, 12)
        .background(Color.black)
    }

    private func button(icon name: String, accessibilityKey: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(name).resizable().scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .frame(width: tapSize, height: tapSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityKey.localized)
    }
}
