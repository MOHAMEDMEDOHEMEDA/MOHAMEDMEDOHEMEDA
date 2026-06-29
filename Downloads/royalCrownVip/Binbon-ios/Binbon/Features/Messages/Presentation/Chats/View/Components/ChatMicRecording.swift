//
//  ChatMicRecording.swift
//  Binbon
//
//  Voice recording gesture + mic icons. State machine:
//    touch-down → 150 ms timer (isHoldPending = true)
//    < 150 ms release → hint tooltip for 2 s
//    ≥ 150 ms → startRecording(), isFingerDown = true
//    drag left > 100 pt → cancel + trash animation
//    drag up   > 90 pt  → lock
//    release   → send voice message
//

import SwiftUI

extension ChatView {

    // Left-bar mic: scales up while hold is pending.
    var startRecordMicIcon: some View {
        ZStack {
            if isHoldPending {
                Circle()
                    .stroke(Color.red.opacity(0.4), lineWidth: 2)
                    .frame(width: 34, height: 34)
                    .scaleEffect(1.25)
                    .opacity(0.7)
            }
            Image("composer-mic")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
        }
        .frame(minWidth: 24, minHeight: 24)
        .contentShape(Rectangle())
        .scaleEffect(isHoldPending ? 1.35 : 1.0)
        .animation(.spring(response: 0.18, dampingFraction: 0.6), value: isHoldPending)
        .gesture(recordingGesture)
        .overlay(alignment: .top) {
            if isShowingHint {
                VoiceHintTooltip()
                    .offset(y: -56)
                    .transition(.scale(scale: 0.85, anchor: .bottom).combined(with: .opacity))
            }
        }
    }

    // Right-side mic shown in the recording bar — same gesture continues tracking.
    var holdMicIcon: some View {
        Image("composer-mic")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            .gesture(recordingGesture)
    }

    var recordingGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                if viewModel.recordingState == .idle && !isCancelling {
                    guard !isHoldPending else { return }
                    isHoldPending = true
                    holdTimer?.invalidate()
                    holdTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                        DispatchQueue.main.async {
                            guard isHoldPending else { return }
                            composerFocused = false
                            showEmojiPicker = false
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            isHoldPending = false
                            isFingerDown = true
                            viewModel.startRecording()
                        }
                    }
                    return
                }
                guard viewModel.recordingState == .recording else { return }
                viewModel.recordingDragOffset = value.translation
                if value.translation.height < -90 {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                        viewModel.lockRecording()
                    }
                }
            }
            .onEnded { value in
                let wasRecording = viewModel.recordingState == .recording
                let wasPending = isHoldPending

                holdTimer?.invalidate()
                holdTimer = nil
                isHoldPending = false
                isFingerDown = false

                if wasPending && !wasRecording {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { isShowingHint = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { isShowingHint = false }
                    }
                    return
                }

                guard wasRecording else { return }

                if abs(value.translation.width) > 100 {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    viewModel.cancelRecording()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) { isCancelling = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                        withAnimation(.spring(response: 0.3)) { isCancelling = false }
                    }
                } else {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        viewModel.sendVoiceMessage()
                    }
                }
            }
    }
}
