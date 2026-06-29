//
//  VoiceComposerBar.swift
//  Binbon
//

import SwiftUI

// MARK: - Recording bar (hold mode)
// Layout: 🔴 mic + timer | ← slide to cancel | 🎤 (scaled when finger down)

struct VoiceRecordingBar: View {
    @ObservedObject var viewModel: ChatViewModel
    let micGestureView: AnyView
    var isFingerDown: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                PulsingMicIcon(color: .red, size: 24)
                Text(viewModel.recordingTimeString)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            .padding(.leading, 16)

            Spacer()

            slideToCancelLabel

            Spacer()

            micGestureView
                .scaleEffect(isFingerDown ? 1.4 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.55), value: isFingerDown)
                .frame(minWidth: 48, minHeight: 48)
                .contentShape(Rectangle())
                .padding(.trailing, 16)
        }
        .frame(height: 52)
    }

    private var slideToCancelLabel: some View {
        let dx = viewModel.recordingDragOffset.width
        return HStack(spacing: 4) {
            Text("voice_slide_cancel".localized)
                .font(.system(size: 14))
            Image(systemName: "chevron.left")
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(.white.opacity(0.85))
        .offset(x: dx * 0.3)
        .opacity(max(0.15, 1.0 - abs(dx) / 100.0))
    }
}

// MARK: - Locked bar (hands-free mode)
// Layout top: timer + live waveform   bottom: 🗑 | ⏸ | ➤

struct VoiceLockedBar: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(viewModel.recordingTimeString)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 52, alignment: .leading)

                LockedWaveform(samples: viewModel.recordedSamples)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            HStack {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.cancelRecording()
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.togglePause()
                } label: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 2)
                            .frame(width: 52, height: 52)
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.sendVoiceMessage()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "25D366"))
                            .frame(width: 52, height: 52)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 30)
        }
    }
}

// MARK: - Lock indicator (floating capsule above mic while dragging up)

struct VoiceLockIndicator: View {
    let dragY: CGFloat

    private var progress: CGFloat { min(1.0, max(0, -dragY / 90.0)) }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: progress >= 1.0 ? "lock.fill" : "lock.open.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.3))
                    .frame(width: 3, height: 30)
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white)
                    .frame(width: 3, height: 30 * progress)
            }

            Image(systemName: "chevron.up")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.5))
        )
        .opacity(Double(min(1, progress * 3)))
        .scaleEffect(0.7 + progress * 0.3)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: progress)
    }
}

// MARK: - Trash-bin cancel animation

struct TrashCancelAnimation: View {
    @State private var trashScale: CGFloat = 0.5
    @State private var trashOpacity: Double = 0
    @State private var lidYOffset: CGFloat = 0
    @State private var micY: CGFloat = -20
    @State private var micScale: CGFloat = 1.0
    @State private var micOpacity: Double = 1.0
    @State private var shakeX: CGFloat = 0

    var body: some View {
        ZStack {
            // Trash bin
            VStack(spacing: 0) {
                // Custom lid (two capsules: handle + bar)
                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(.white)
                        .frame(width: 38, height: 5)
                    Capsule()
                        .fill(.white)
                        .frame(width: 14, height: 5)
                        .offset(y: -4)
                }
                .offset(y: lidYOffset)
                .zIndex(1)

                Image(systemName: "trash.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(.white)
            }
            .scaleEffect(trashScale)
            .opacity(trashOpacity)
            .offset(x: shakeX)

            // Mic icon that falls into the bin
            Image("composer-mic")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 24, height: 24)
                .scaleEffect(micScale)
                .opacity(micOpacity)
                .offset(y: micY)
        }
        .onAppear { runAnimation() }
    }

    private func runAnimation() {
        Task { @MainActor in
            // 1. Trash materialises
            withAnimation(.spring(response: 0.2, dampingFraction: 0.65)) {
                trashScale = 1.0; trashOpacity = 1.0
            }
            try? await Task.sleep(for: .milliseconds(120))

            // 2. Lid swings open
            withAnimation(.spring(response: 0.18, dampingFraction: 0.5)) {
                lidYOffset = -18
            }
            try? await Task.sleep(for: .milliseconds(100))

            // 3. Mic drops in
            withAnimation(.easeIn(duration: 0.22)) {
                micY = 22; micScale = 0.35; micOpacity = 0
            }
            try? await Task.sleep(for: .milliseconds(270))

            // 4. Lid slams shut with overshoot
            withAnimation(.spring(response: 0.18, dampingFraction: 0.38)) { lidYOffset = 6 }
            try? await Task.sleep(for: .milliseconds(170))
            withAnimation(.spring(response: 0.14, dampingFraction: 0.75)) { lidYOffset = 0 }
            try? await Task.sleep(for: .milliseconds(140))

            // 5. Bin shakes
            for dx in [-6, 5, -3, 2, 0] as [CGFloat] {
                withAnimation(.spring(response: 0.07, dampingFraction: 0.28)) { shakeX = dx }
                try? await Task.sleep(for: .milliseconds(65))
            }

            // 6. Fade out
            withAnimation(.easeOut(duration: 0.22)) {
                trashOpacity = 0; trashScale = 0.55
            }
        }
    }
}

// MARK: - Hint tooltip ("Hold to record, release to send")

struct VoiceHintTooltip: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("voice_hold_hint".localized)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.black.opacity(0.72))
                )

            // Downward pointer triangle
            TooltipTriangle()
                .fill(Color.black.opacity(0.72))
                .frame(width: 10, height: 6)
        }
    }
}

private struct TooltipTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Waveform in locked mode

private struct LockedWaveform: View {
    let samples: [CGFloat]
    private let barWidth: CGFloat = 2.5
    private let spacing: CGFloat = 1.5
    private let maxHeight: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let maxBars = Int(geo.size.width / (barWidth + spacing))
            let display = tailSamples(maxBars: maxBars)

            HStack(alignment: .center, spacing: spacing) {
                ForEach(0..<display.count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(.white.opacity(0.9))
                        .frame(width: barWidth, height: max(3, display[i] * maxHeight))
                }
                if display.count < maxBars {
                    ForEach(0..<(maxBars - display.count), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(.white.opacity(0.2))
                            .frame(width: barWidth, height: 3)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
        }
    }

    private func tailSamples(maxBars: Int) -> [CGFloat] {
        guard !samples.isEmpty else { return [] }
        if samples.count <= maxBars { return samples }
        let stride = Double(samples.count) / Double(maxBars)
        return (0..<maxBars).map { i in
            let start = Int(Double(i) * stride)
            let end = min(Int(Double(i + 1) * stride), samples.count)
            guard end > start else { return samples[start] }
            return samples[start..<end].reduce(0, +) / CGFloat(end - start)
        }
    }
}

// MARK: - Shared primitives

struct PulsingMicIcon: View {
    var color: Color = .white
    var size: CGFloat = 24
    @State private var pulsing = false

    var body: some View {
        Image("composer-mic")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .scaleEffect(pulsing ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: pulsing)
            .onAppear { pulsing = true }
    }
}

struct WaveformBars: View {
    private let count = 14

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.06)) { ctx in
            HStack(spacing: 2) {
                ForEach(0..<count, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 2.5, height: barHeight(index: i, date: ctx.date))
                }
            }
        }
    }

    private func barHeight(index: Int, date: Date) -> CGFloat {
        let t = date.timeIntervalSinceReferenceDate
        let a = sin(t * 7.0 + Double(index) * 0.9) * 0.45
        let b = sin(t * 4.0 + Double(index) * 0.5) * 0.3
        let c = sin(t * 2.5 + Double(index) * 1.3) * 0.2
        return CGFloat(6 + (a + b + c + 0.5) * 10)
    }
}
