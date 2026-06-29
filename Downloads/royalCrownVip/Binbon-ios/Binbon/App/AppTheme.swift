//
//  AppThemeModifier.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

private struct AppThemeModifier: ViewModifier {

    @ObservedObject private var theme = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .appBackground()
            .environmentObject(theme)
            .preferredColorScheme(theme.preferredColorScheme)
            .onAppear { theme.systemScheme = colorScheme }
            .onChange(of: colorScheme) { theme.systemScheme = colorScheme }
    }

}

extension View {
    func theme() -> some View {
        self.modifier(AppThemeModifier())
    } 
}
