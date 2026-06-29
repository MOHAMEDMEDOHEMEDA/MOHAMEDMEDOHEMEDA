//
//  VoiceCallBackground.swift
//  Binbon
//

import SwiftUI

/// Blurred, dimmed avatar used as the full-screen backdrop of a one-to-one call.
struct VoiceCallBackground: View {
    let avatarURL: String?
    let avatarAsset: String

    @ObservedObject private var theme = ThemeManager.shared

    var body: some View {
        GeometryReader { proxy in
            CallAvatarImage(avatarURL: avatarURL, avatarAsset: avatarAsset)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .blur(radius: 28)
                .overlay(Color.black.opacity(theme.mode == .colored ? 0.38 : 0.48))
                .clipped()
        }
        .ignoresSafeArea()
    }
}
