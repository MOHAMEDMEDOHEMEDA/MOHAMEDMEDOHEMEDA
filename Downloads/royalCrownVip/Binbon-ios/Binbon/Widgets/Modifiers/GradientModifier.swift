//
//  GradientModifier.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

private struct GradientModifier: ViewModifier {

    // Observing the manager re-renders this on in-app theme switches
    // (e.g. Dark → Colored, where the device trait doesn't change).
    @ObservedObject private var theme = ThemeManager.shared

    func body(content: Content) -> some View {
        ZStack {
            // Dynamic gradient: re-resolves on every system appearance
            // change too, so the background repaints live with the rest of
            // the app chrome — no tab switch needed.
            AppColor.backgroundGradientApp
                .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(GradientModifier())
    }

    func orangeBottomGradientBackground() -> some View {
        ZStack {
            AppColor.orangeBottomGradient
                .ignoresSafeArea()
            self
        }
    }
}
