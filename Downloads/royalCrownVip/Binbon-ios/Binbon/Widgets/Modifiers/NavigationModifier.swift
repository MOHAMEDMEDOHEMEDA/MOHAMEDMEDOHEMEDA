//
//  NavigationModifier.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

private struct NavigationModifier: ViewModifier {

    let title: String?

    @ObservedObject private var theme = ThemeManager.shared

    func body(content: Content) -> some View {
        content
            // Title / bar-button ink follows the theme: dark on Light,
            // white on Dark / Colored, automatic on System.
            .toolbarColorScheme(theme.preferredColorScheme, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbarRole(.navigationStack)
            .if(title != nil) {
                $0.navigationTitle(title ?? "")
            }
    }
}

extension View {
    func appNavigation(title: String? = nil) -> some View {
        modifier(NavigationModifier(title: title))
    }
}
