//
//  ThemeSettingView.swift
//  Binbon
//
//  Created by Mrwan hany on 04/06/2026.
//

import SwiftUI

struct ThemeSettingView: View {

    @ObservedObject private var theme = ThemeManager.shared

    /// Display order requested in the design: Light, Dark, Colored, System.
    private let modes: [AppThemeMode] = [.light, .dark, .colored, .system]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(modes, id: \.rawValue) { mode in
                    ThemeSwitchRow(
                        title: mode.title,
                        isOn: theme.mode == mode
                    ) {
                        theme.select(mode)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "appearance_theme_settings".localized)
    }
}

// MARK: - Theme Switch Row
private struct ThemeSwitchRow: View {

    let title: String
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        // Label on the leading side, switch on the trailing side.
        // SwiftUI mirrors the HStack automatically for Arabic (RTL).
        HStack {
            Text(title)
                .foregroundStyle(.appText)
                .font(.subheadline.weight(.semibold))

            Spacer()

            Capsule()
                .fill(isOn ? Color(hex: "4CD964") : Color(hex: "C0C0C0"))
                .frame(width: 34, height: 17)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: 13, height: 13)
                        .padding(2)
                        .frame(maxWidth: .infinity,
                               alignment: isOn ? .trailing : .leading)
                )
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    NavigationView {
        ThemeSettingView()
    }
}
