//
//  UtilityControlButton.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓲𝓮𝓷 on 23/06/2026.
//

import SwiftUI

struct UtilityControlButton: View {

    var icon: String?
    var systemName: String?
    var showsDisabledStrike: Bool = false
    let accessibilityKey: String
    var buttonSize: CGFloat = 46
    var iconSize: CGFloat = 23
    var isProminent: Bool = false
    var iconWidth: CGFloat?
    var iconHeight: CGFloat?
    var showsBackground: Bool = true
    var action: (() -> Void)?

    init(
        icon: String? = nil,
        systemName: String? = nil,
        showsDisabledStrike: Bool = false,
        accessibilityKey: String,
        buttonSize: CGFloat = 46,
        iconSize: CGFloat = 23,
        isProminent: Bool = false,
        iconWidth: CGFloat? = nil,
        iconHeight: CGFloat? = nil,
        showsBackground: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.systemName = systemName
        self.showsDisabledStrike = showsDisabledStrike
        self.accessibilityKey = accessibilityKey
        self.buttonSize = buttonSize
        self.iconSize = iconSize
        self.isProminent = isProminent
        self.iconWidth = iconWidth
        self.iconHeight = iconHeight
        self.showsBackground = showsBackground
        self.action = action
    }

    private var resolvedIconWidth: CGFloat { iconWidth ?? iconSize }
    private var resolvedIconHeight: CGFloat { iconHeight ?? iconSize }

    var body: some View {
        Button {
            action?()
        } label: {
            ZStack {
                
                Circle()
                    .fill(
                        isProminent
                            ? AnyShapeStyle(AppColor.verificationGradient)
                            : AnyShapeStyle(AppColor.voiceCallControlButtonFill)
                    )
                    .fill(AppColor.voiceCallControlButtonFillGredient)
                    .frame(width: buttonSize, height: buttonSize)

                ZStack {
                    if let icon {
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: resolvedIconWidth, height: resolvedIconHeight)
                            .environment(\.layoutDirection, .leftToRight)
                            .flipsForRightToLeftLayoutDirection(false)
                    } else if let systemName {
                        Image(systemName: systemName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                            .foregroundStyle(.white)
                    }

                    if showsDisabledStrike {
                        Rectangle()
                            .fill(Color(hex: "FF3B30"))
                            .frame(width: 30, height: 2.5)
                            .rotationEffect(.degrees(-42))
                    }
                }
                .frame(width: iconSize, height: iconSize)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityKey.localized)
    }
}

#Preview {
    HStack(spacing: 16) {
        UtilityControlButton(
            icon: "calls-moreoption",
            accessibilityKey: "voice_call_keypad"
        )
        UtilityControlButton(
            systemName: "video.fill",
            showsDisabledStrike: true,
            accessibilityKey: "voice_call_video"
        )
        UtilityControlButton(
            icon: "calls-mute",
            accessibilityKey: "voice_call_speaker"
        )
    }
    .padding()
    .background(Color.black.opacity(0.3))
    .padding()
}
