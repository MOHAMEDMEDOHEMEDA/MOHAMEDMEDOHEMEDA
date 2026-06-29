//
//  CreateVideoViewImageOverlay.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewImageOverlay: View {

    @ObservedObject var viewModel: CreateVideoViewModel

    @Binding var overlayOffset: CGSize
    @Binding var overlayOffsetBase: CGSize
    @Binding var overlayScale: CGFloat
    @Binding var overlayScaleBase: CGFloat
    @Binding var overlayRotation: Angle
    @Binding var overlayRotationBase: Angle

    @Binding var screenSize: CGSize
    @Binding var isDraggingOverlay: Bool
    @Binding var isOverTrash: Bool

    var body: some View {
        if viewModel.layout == .single, let image = viewModel.primaryImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200, maxHeight: 300)
                .scaleEffect(overlayScale * (isOverTrash ? 0.7 : 1))
                .rotationEffect(overlayRotation)
                .opacity(isOverTrash ? 0.55 : 1)
                .offset(overlayOffset)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isOverTrash)
                .gesture(
                    overlayDragGesture.simultaneously(
                        with: overlayPinchGesture.simultaneously(with: overlayRotationGesture))
                )
        }
    }

    private var overlayDragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                overlayOffset = CGSize(
                    width: overlayOffsetBase.width + value.translation.width,
                    height: overlayOffsetBase.height + value.translation.height)

                isDraggingOverlay = true
                let nowOverTrash = isLocationOverTrash(value.location)
                if nowOverTrash != isOverTrash {
                    isOverTrash = nowOverTrash
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            .onEnded { _ in
                if isOverTrash {
                    viewModel.clearSelectedImage()
                    overlayOffset = .zero; overlayOffsetBase = .zero
                    overlayScale = 1; overlayScaleBase = 1
                    overlayRotation = .zero; overlayRotationBase = .zero
                } else {
                    overlayOffsetBase = overlayOffset
                }
                isDraggingOverlay = false
                isOverTrash = false
            }
    }

    private var overlayPinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in overlayScale = min(4, max(0.3, overlayScaleBase * scale)) }
            .onEnded { _ in overlayScaleBase = overlayScale }
    }

    private var overlayRotationGesture: some Gesture {
        RotationGesture()
            .onChanged { angle in overlayRotation = overlayRotationBase + angle }
            .onEnded { _ in overlayRotationBase = overlayRotation }
    }

    private func isLocationOverTrash(_ point: CGPoint) -> Bool {
        guard screenSize != .zero else { return false }
        let center = CGPoint(x: screenSize.width / 2, y: screenSize.height - 80)
        return hypot(point.x - center.x, point.y - center.y) < 90
    }
}
