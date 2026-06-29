//
//  ScreenLoadingModifier.swift
//  Binbon
//
//  Shows the bundled Lottie animation as a full-screen intro overlay when a
//  screen opens, then reveals the screen once the animation finishes.
//

import SwiftUI
import Lottie

/// Name of the bundled Lottie loading animation (Resources/Lottie).
private let loadingAnimationName = "loading_animation"

private struct ScreenLoadingModifier: ViewModifier {

    /// Whether this screen is the one on display. For navigation-pushed screens
    /// it's always true (plays once on open); for the kept-alive bottom tabs it's
    /// `tab == item`, so the overlay replays each time the tab becomes active.
    let isActive: Bool

    @State private var isLoading: Bool
    @State private var playToken = UUID()

    /// Matches the bundled animation length (~2.4s at 24fps) plus a buffer, so the
    /// overlay always clears even if the animation can't report completion.
    private let safetyTimeout: TimeInterval = 3.5

    init(isActive: Bool) {
        self.isActive = isActive
        _isLoading = State(initialValue: isActive)
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            if isLoading {
                overlay
                    .id(playToken)
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .onChange(of: isActive) { _, nowActive in
            if nowActive { replay() }
        }
    }

    private var overlay: some View {
        ZStack {
            // Translucent dim so the screen behind shows through a little while the
            // animation plays, rather than fully hiding it.
            Color.black.opacity(0.55)

            LottieView(name: loadingAnimationName) { finish() }
                .frame(width: 180, height: 180)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .task(id: playToken) {
            try? await Task.sleep(nanoseconds: UInt64(safetyTimeout * 1_000_000_000))
            finish()
        }
    }

    private func finish() {
        guard isLoading else { return }
        withAnimation(.easeOut(duration: 0.3)) { isLoading = false }
    }

    private func replay() {
        playToken = UUID()
        withAnimation(.easeOut(duration: 0.2)) { isLoading = true }
    }
}

extension View {
    /// Covers the screen with the Lottie loading animation until it finishes,
    /// then reveals the content. `isActive` defaults to true (play once on open);
    /// pass `tab == item` for kept-alive tabs so it replays on each selection.
    func screenLoading(isActive: Bool = true) -> some View {
        modifier(ScreenLoadingModifier(isActive: isActive))
    }

    /// Dims the screen and shows the looping Lottie animation while `isLoading`
    /// is true — used for in-flight actions (e.g. logging in / creating an
    /// account) where the overlay clears once the work navigates away.
    func loadingOverlay(_ isLoading: Bool) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading))
    }
}

/// A translucent, dimmed overlay with the looping loading animation, shown over
/// the content while an action is in progress.
private struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.45)
                        LottieView(name: loadingAnimationName, loopMode: .loop)
                            .frame(width: 150, height: 150)
                    }
                    .ignoresSafeArea()
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}
