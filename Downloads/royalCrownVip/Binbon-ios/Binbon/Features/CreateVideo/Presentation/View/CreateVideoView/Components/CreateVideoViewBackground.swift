//
//  CreateVideoViewBackground.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewBackground: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    @ObservedObject var camera: CameraManager
    @Binding var zoom: CGFloat
    @Binding var zoomBase: CGFloat

    var body: some View {
        CreateVideoViewPreviewLayout(viewModel: viewModel, camera: camera, zoom: zoom)
            .gesture(zoomGesture)
            .onTapGesture(count: 2) {
                if viewModel.capturedVideoURL == nil { camera.flipCamera() }
            }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in setZoom(zoomBase * scale) }
            .onEnded { _ in zoomBase = zoom }
    }

    private func setZoom(_ value: CGFloat) {
        zoom = min(5, max(1, value))
    }
}
