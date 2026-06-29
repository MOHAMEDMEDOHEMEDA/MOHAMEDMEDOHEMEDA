//
//  CreateVideoViewRecordingTimer.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewRecordingTimer: View {

    @ObservedObject var camera: CameraManager
    let recordedSeconds: Int

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: "E14554"))
                .frame(width: 9, height: 9)
            Text(timeString(camera.isRecording ? camera.recordingSeconds : recordedSeconds))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.35), in: Capsule())
        .frame(height: 44)
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
