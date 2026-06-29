//
//  FloatingAssistiveButton.swift
//  Binbon
//
//  An AssistiveTouch-style floating button overlaid app-wide once the user is on
//  the home root. It idles with a gentle bob and rising bubbles, can be dragged
//  anywhere (snapping to the nearest edge), opens the verification intro page on
//  a tap, and hides for 5 minutes via the top-right close button.
//

import SwiftUI
import UIKit

// MARK: - Overlay

/// Hosts the button above all in-app content. Visible only while the home root is
/// active (i.e. the user is signed in) and not temporarily hidden.
struct FloatingAssistiveButtonOverlay: View {

    @ObservedObject private var router = AppRouter.shared
    @ObservedObject private var state = AssistiveButtonState.shared

    private var isVisible: Bool {
        router.route == .home && !state.isHidden && !router.showSplash
    }

    var body: some View {
        GeometryReader { geo in
            if isVisible {
                FloatingAssistiveButton(bounds: geo.size)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        // The button is positioned with absolute coordinates and a global-space
        // drag; pin LTR so RTL (Arabic) doesn't mirror `.position`, the snap-edge
        // math, or the top-trailing close button.
        .environment(\.layoutDirection, .leftToRight)
        .ignoresSafeArea()
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isVisible)
    }
}

// MARK: - Button

struct FloatingAssistiveButton: View {

    let bounds: CGSize

    @ObservedObject private var state = AssistiveButtonState.shared

    private let size: CGFloat = 64
    private let edgeInset: CGFloat = 10
    private let tapSlop: CGFloat = 10

    @State private var position: CGPoint
    @State private var isDragging = false
    @State private var bob = false

    // Manual gesture arbitration: one drag gesture distinguishes tap from drag,
    // which composes far more reliably than stacking SwiftUI gestures.
    @State private var dragStart: CGPoint?

    init(bounds: CGSize) {
        self.bounds = bounds
        _position = State(initialValue: CGPoint(x: bounds.width - 64 / 2 - 10,
                                                y: bounds.height * 0.62))
    }

    var body: some View {
        ZStack {
            BubbleEmitter(size: size)
                .allowsHitTesting(false)

            badge
                .offset(y: bob ? -6 : 6)
        }
        .frame(width: size, height: size)
        .position(position)
        .gesture(gesture)
        .onAppear {
            if let saved = state.position { position = saved }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                bob = true
            }
        }
    }

    // MARK: Badge

    private var badge: some View {
        ZStack {
            // Same gradient as the verification page background for a cohesive look.
            Circle().fill(AppColor.verificationGradient)
            Circle().stroke(Color.black, lineWidth: 1.5)

            // TODO: missing asset — white verified seal badge (the project's
            // Reg_Verify asset is blue). Using an SF Symbol placeholder for now.
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(alignment: .topTrailing) {
            closeButton.offset(x: 2, y: -2)
        }
        .scaleEffect(isDragging ? 1.1 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isDragging)
    }

    // MARK: Close

    /// Dismisses the floating button (hides it for 5 minutes). Replaces the old
    /// long-press-to-hide gesture with an explicit tappable control.
    private var closeButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            state.hideTemporarily()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.black.opacity(0.55)))
                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: Gesture

    private var gesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                if dragStart == nil { dragStart = position }
                let moved = hypot(value.translation.width, value.translation.height)
                if moved > tapSlop { isDragging = true }
                if isDragging, let start = dragStart {
                    // Track the finger 1:1 with animations disabled so the drag
                    // never re-times the bubbles' rising loop or the idle bob.
                    var t = SwiftUI.Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) {
                        position = CGPoint(x: start.x + value.translation.width,
                                           y: start.y + value.translation.height)
                    }
                }
            }
            .onEnded { value in
                let moved = hypot(value.translation.width, value.translation.height)
                defer {
                    dragStart = nil
                    isDragging = false
                }
                if moved < tapSlop {
                    AppRouter.shared.navigate(.verificationIntro)
                } else {
                    snapToEdge()
                }
            }
    }

    private func snapToEdge() {
        let half = size / 2
        let minX = half + edgeInset
        let maxX = bounds.width - half - edgeInset
        let minY = half + 60
        let maxY = bounds.height - half - 100

        let targetX = position.x < bounds.width / 2 ? minX : maxX
        let clampedY = min(max(position.y, minY), maxY)

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            position = CGPoint(x: targetX, y: clampedY)
        }
        state.position = CGPoint(x: targetX, y: clampedY)
    }
}

// MARK: - Bubbles

/// Decorative bubbles that rise from the button and fade, looping forever.
///
/// Driven off a `TimelineView` clock rather than implicit state animations: each
/// bubble's offset/opacity is a pure function of the current time, so dragging
/// the button (which re-renders this view every frame) can't restart, reshuffle,
/// or jump the bubbles — they stay exactly as they were.
private struct BubbleEmitter: View {
    let size: CGFloat

    private let count = 6

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    bubble(i, time: t)
                }
            }
        }
    }

    @ViewBuilder
    private func bubble(_ i: Int, time: Double) -> some View {
        let dim = bubbleSize(i)
        // Looping 0→1 progress for this bubble's rise.
        let phase = (((time + delay(i)) / duration(i)).truncatingRemainder(dividingBy: 1) + 1)
            .truncatingRemainder(dividingBy: 1)
        let rise = -size * (0.2 + 1.7 * phase)

        ZStack {
            Circle().fill(AppColor.verificationGradient)
            Circle().stroke(Color.black, lineWidth: 1)
            Image(systemName: icon(i))
                .font(.system(size: dim * 0.5, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: dim, height: dim)
        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
        .opacity(0.9 * (1 - phase))
        .offset(x: xOffset(i), y: rise)
    }

    // Deterministic per-index variation so bubbles read as organic without RNG.
    private func bubbleSize(_ i: Int) -> CGFloat { [28, 22, 32, 24, 30, 20][i % 6] }
    private func xOffset(_ i: Int) -> CGFloat { [-20, 16, -6, 22, -16, 10][i % 6] }
    private func duration(_ i: Int) -> Double { [2.2, 2.8, 2.0, 3.0, 2.5, 3.2][i % 6] }
    private func delay(_ i: Int) -> Double { Double(i) * 0.45 }
    private func icon(_ i: Int) -> String {
        ["gift.fill", "dollarsign", "dot.radiowaves.left.and.right",
         "star.fill", "heart.fill", "bell.fill"][i % 6]
    }
}
