//
//  CreateVideoViewControlRail.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewControlRail: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    @ObservedObject var camera: CameraManager
    @ObservedObject var effects: VideoEffectsState
    @Binding var showDurations: Bool
    @Binding var showLayouts: Bool
    let controlTint: Color

    private let activeTint = Color(hex: "FBBC05")

    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(visibleControls.enumerated()), id: \.offset) { _, control in
                Button(action: control.action) {
                    VStack(spacing: 2) {
                        Image(systemName: control.icon)
                            .font(.system(size: 20, weight: .medium))
                        if control.icon == "timer", effects.countdown > 0 {
                            Text("\(effects.countdown)s")
                                .font(.system(size: 9, weight: .bold))
                        }
                    }
                    .foregroundStyle(tint(for: control))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            Button { withAnimation(.easeInOut(duration: 0.2)) { effects.railExpanded.toggle() } } label: {
                Image(systemName: effects.railExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(controlTint)
                    .frame(width: 44, height: 36)
                    .background(.white.opacity(0.12), in: Circle())
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func tint(for control: VideoSideControl) -> Color {
        if control.isDestructive { return .red }
        return control.isActive ? activeTint : controlTint
    }

    private var primaryControls: [VideoSideControl] {
        [
            VideoSideControl(icon: "arrow.triangle.2.circlepath") { camera.flipCamera() },
            VideoSideControl(icon: "camera.filters",
                             isActive: effects.panel == .filters) {
                withAnimation { showDurations = false; effects.togglePanel(.filters) }
            }
        ]
    }

    private var secondaryControls: [VideoSideControl] {
        [
            VideoSideControl(icon: "sparkles",
                             isActive: effects.panel == .effects) {
                withAnimation { showDurations = false; effects.togglePanel(.effects) }
            },
            VideoSideControl(icon: "wand.and.stars",
                             isActive: effects.beauty) {
                withAnimation { effects.beauty.toggle() }
            },
            VideoSideControl(icon: "speedometer",
                             isActive: effects.panel == .speed) {
                withAnimation { showDurations = false; effects.togglePanel(.speed) }
            },
            VideoSideControl(icon: "clock",
                             isActive: showDurations) {
                withAnimation { effects.panel = .none; showLayouts = false; showDurations.toggle() }
            },
            VideoSideControl(icon: "rectangle.split.2x1",
                             isActive: showLayouts) {
                withAnimation { effects.panel = .none; showDurations = false; showLayouts.toggle() }
            },
            VideoSideControl(icon: "timer",
                             isActive: effects.countdown > 0) {
                withAnimation { effects.cycleCountdown() }
            },
            VideoSideControl(icon: camera.flashEnabled ? "bolt.fill" : "bolt.slash.fill",
                             isActive: camera.flashEnabled) { camera.toggleFlash() },
            VideoSideControl(icon: camera.isMuted ? "mic.slash.fill" : "mic.fill",
                             isDestructive: camera.isMuted) { camera.toggleMute() },
            VideoSideControl(icon: "person.badge.plus") { viewModel.showShareSheet = true }
        ]
    }

    private var visibleControls: [VideoSideControl] {
        var controls = effects.railExpanded ? primaryControls + secondaryControls : primaryControls
        if viewModel.capturedVideoURL != nil {
            controls.insert(VideoSideControl(icon: "scissors") { viewModel.showTrim = true }, at: 0)
        }
        return controls
    }
}
