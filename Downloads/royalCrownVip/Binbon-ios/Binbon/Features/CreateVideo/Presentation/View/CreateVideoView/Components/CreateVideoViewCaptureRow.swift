//
//  CreateVideoViewCaptureRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import Combine
import SwiftUI

struct CreateVideoViewCaptureRow: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    @ObservedObject var camera: CameraManager
    let chipBackground: Color
    var countdownMode: Bool = false
    var onRecordTap: () -> Void = {}
    var onDiscard: () -> Void = {}
    var onConfirm: () -> Void = {}

    @Binding var zoom: CGFloat
    @Binding var recordZoomBase: CGFloat
    @Binding var isHoldingRecord: Bool
    @Binding var isLocked: Bool
    @Binding var lockArmed: Bool

    private var reviewing: Bool { camera.hasSegments && !camera.isRecording }

    var body: some View {
        ZStack {
            CreateVideoViewRecordButton(viewModel: viewModel,
                                        camera: camera,
                                        countdownMode: countdownMode,
                                        onRecordTap: onRecordTap,
                                        zoom: $zoom,
                                        recordZoomBase: $recordZoomBase,
                                        isHoldingRecord: $isHoldingRecord,
                                        isLocked: $isLocked,
                                        lockArmed: $lockArmed)

            HStack(alignment: .center) {
                if camera.isRecording {
                    CreateVideoViewLockButton(armed: lockArmed || isLocked)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    CreateVideoViewGalleryButton(viewModel: viewModel, chipBackground: chipBackground)
                }
                Spacer()
                if reviewing {
                    HStack(spacing: 14) {
                        CreateVideoViewDiscardButton { onDiscard() }
                        CreateVideoViewConfirmButton { onConfirm() }
                    }
                } else {
                    Color.clear.frame(width: 52, height: 52)
                }
            }
            .padding(.horizontal, 40)
        }
        .animation(.easeInOut(duration: 0.2), value: camera.isRecording)
        .animation(.easeInOut(duration: 0.15), value: isHoldingRecord)
    }
}
