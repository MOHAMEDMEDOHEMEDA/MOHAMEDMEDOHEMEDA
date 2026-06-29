//
//  CreateVideoViewRecordButton.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import Combine
import SwiftUI

struct CreateVideoViewRecordButton: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    @ObservedObject var camera: CameraManager
    var countdownMode: Bool = false
    var onRecordTap: () -> Void = {}

    @Binding var zoom: CGFloat
    @Binding var recordZoomBase: CGFloat
    @Binding var isHoldingRecord: Bool
    @Binding var isLocked: Bool
    @Binding var lockArmed: Bool

    private let segColorB = AnyShapeStyle(
        LinearGradient(colors: [Color(hex: "FFAAB3"), Color(hex: "83489C")],
                       startPoint: .leading, endPoint: .trailing)
    )
    private let segColorA = AnyShapeStyle(Color(hex: "FBBC05"))

    private var usesTap: Bool { isLocked }

    var body: some View {
        let active = camera.isRecording || camera.hasSegments
        return ZStack {
            Circle()
                .stroke(.white.opacity(0.8), lineWidth: active ? 16 : 10)
                .frame(width: active ? 84 : 100, height: active ? 84 : 100)

            if active {
                ForEach(Array(arcs.enumerated()), id: \.offset) { _, arc in
                    Circle()
                        .trim(from: arc.start, to: arc.end)
                        .stroke(arc.color, style: StrokeStyle(lineWidth: 6, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 84, height: 84)
                        .animation(.linear(duration: 0.3), value: arc.end)
                }
            }

            Circle()
                .fill(
                    active
                        ? AnyShapeStyle(Color(hex: "E14554"))
                        : AnyShapeStyle(LinearGradient(colors: [Color(hex: "E2704A"), Color(hex: "8E4C9E")],
                                                       startPoint: .top, endPoint: .bottom))
                )
                .frame(width: active ? 68 : 100, height: active ? 68 : 100)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 4)

            Image("record-binbon-logo")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: active ? 40 : 70, height: active ? 40 : 70)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: active)
        .contentShape(Circle())
        .gesture(recordGesture, including: usesTap ? .subviews : .all)
        .simultaneousGesture(TapGesture().onEnded { onRecordTap() })
    }

    private var arcs: [(start: Double, end: Double, color: AnyShapeStyle)] {
        let total = max(1, Double(camera.maxSeconds))
        var result: [(Double, Double, AnyShapeStyle)] = []
        var cursor = 0.0
        for index in camera.segmentDurations.indices {
            let frac = camera.segmentDurations[index] / total
            let end = min(1, cursor + frac)
            let take = index < camera.segmentTakes.count ? camera.segmentTakes[index] : index
            result.append((cursor, end, take.isMultiple(of: 2) ? segColorA : segColorB))
            cursor = end
        }
        if camera.isRecording {
            let frac = camera.recordingElapsed / total
            let end = min(1, cursor + frac)
            result.append((cursor, end, camera.currentTake.isMultiple(of: 2) ? segColorA : segColorB))
        }
        return result
    }

    private var recordGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                guard case .second(true, let drag) = value else { return }
                if !isHoldingRecord {
                    isHoldingRecord = true
                    recordZoomBase = zoom
                    camera.startRecording()
                }
                if let drag {
                    let dragUp = -drag.translation.height
                    setZoom(recordZoomBase + dragUp / 120)
                    lockArmed = -drag.translation.width > 110
                }
            }
            .onEnded { _ in
                isHoldingRecord = false
                if lockArmed {
                    lockArmed = false
                    isLocked = true
                } else {
                    camera.stopRecording()
                }
            }
    }

    private func setZoom(_ value: CGFloat) {
        zoom = min(5, max(1, value))
    }
}
