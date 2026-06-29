//
//  CreateVideoViewBottomPanel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewBottomPanel: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    @ObservedObject var camera: CameraManager
    @ObservedObject var effects: VideoEffectsState

    let showDurations: Bool
    var showLayouts: Bool = false
    let recordedSeconds: Int
    let recordedProgress: Double
    let durations: [(String, Int)]
    let controlTint: Color
    let chipBackground: Color
    let onRecordTap: () -> Void
    let onDiscard: () -> Void
    let onConfirm: () -> Void

    @Binding var zoom: CGFloat
    @Binding var recordZoomBase: CGFloat
    @Binding var isHoldingRecord: Bool
    @Binding var isLocked: Bool
    @Binding var lockArmed: Bool

    var body: some View {
        VStack(spacing: 40) {
            if viewModel.showPublish {
                CreateVideoViewPublishRow(viewModel: viewModel)
            } else {
                if camera.isRecording || camera.hasSegments {
                    CreateVideoViewRecordingTimer(camera: camera, recordedSeconds: recordedSeconds)
                } else if effects.panel == .filters {
                    CreateVideoViewFilterCarousel(effects: effects)
                } else if effects.panel == .effects {
                    CreateVideoViewEffectCarousel(effects: effects)
                } else if effects.panel == .speed {
                    CreateVideoViewSpeedBar(effects: effects)
                } else if showLayouts {
                    CreateVideoViewLayoutSelector(viewModel: viewModel,
                                                  controlTint: controlTint,
                                                  chipBackground: chipBackground)
                } else {
                    CreateVideoViewDurationOptions(camera: camera, durations: durations)
                }

                CreateVideoViewCaptureRow(viewModel: viewModel,
                                          camera: camera,
                                          chipBackground: chipBackground,
                                          countdownMode: effects.countdown > 0,
                                          onRecordTap: onRecordTap,
                                          onDiscard: onDiscard,
                                          onConfirm: onConfirm,
                                          zoom: $zoom,
                                          recordZoomBase: $recordZoomBase,
                                          isHoldingRecord: $isHoldingRecord,
                                          isLocked: $isLocked,
                                          lockArmed: $lockArmed)

                if !camera.isRecording {
                    CreateVideoViewModeSelector(mode: $viewModel.captureMode)
                }
            }
        }
        .padding(.bottom, 24)
        .padding(.top, 16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.85)],
                           startPoint: .top, endPoint: .bottom)
        )
    }
}
