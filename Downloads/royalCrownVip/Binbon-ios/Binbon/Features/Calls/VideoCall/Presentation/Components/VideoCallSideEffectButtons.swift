//
//  VideoCallSideEffectButtons.swift
//  Binbon
//

import SwiftUI

/// Floating left-edge rail toggling the filters / backgrounds effect strips. Tapping an
/// active button collapses back to the standard dock.
struct VideoCallSideEffectButtons: View {

    @Binding var bottomPanelMode: VideoCallBottomPanelMode

    var body: some View {
        VStack(spacing: 12) {
            CallSideButton(icon: "calls-filter", accessibilityKey: "voice_call_filters", iconSize: 31,
                           isActive: bottomPanelMode == .filters) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    bottomPanelMode = bottomPanelMode == .filters ? .standard : .filters
                }
            }

            CallSideButton(icon: "calls-background", accessibilityKey: "voice_call_background", iconSize: 27,
                           isActive: bottomPanelMode == .backgrounds) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    bottomPanelMode = bottomPanelMode == .backgrounds ? .standard : .backgrounds
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background {
            Capsule()
                .fill(AppColor.backgroundGradient.opacity(0.7))
                .overlay {
                    Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1)
                }
        }
        .padding(.leading, 4)
    }
}
