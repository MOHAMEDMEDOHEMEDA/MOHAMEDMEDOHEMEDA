//
//  CreateVideoViewPreviewLayout.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewPreviewLayout: View {

    @ObservedObject var viewModel: CreateVideoViewModel
    @ObservedObject var camera: CameraManager
    let zoom: CGFloat

    var body: some View {
        GeometryReader { geo in
            let panes = viewModel.layout.panes(for: geo.size)

            ZStack(alignment: .topLeading) {
                Color.black

                if let url = viewModel.capturedVideoURL {
                    LoopingPlayer(url: url,
                                  volume: (viewModel.showEditor || viewModel.showPostDetails) ? 0 : 1)
                        .frame(width: panes.camera.width, height: panes.camera.height)
                        .clipped()
                        .position(x: panes.camera.midX, y: panes.camera.midY)
                } else if camera.isAuthorized {
                    CameraPreview(session: camera.session)
                        .frame(width: panes.camera.width, height: panes.camera.height)
                        .clipped()
                        .position(x: panes.camera.midX, y: panes.camera.midY)
                } else {
                    CreateVideoViewPermissionFallback()
                }

                if let imageRect = panes.image {
                    CreateVideoViewImagePane(corner: panes.imageIsCorner,
                                             image: viewModel.primaryImage,
                                             zoom: zoom)
                        .frame(width: imageRect.width, height: imageRect.height)
                        .clipShape(RoundedRectangle(cornerRadius: panes.imageIsCorner ? 14 : 0))
                        .overlay(
                            RoundedRectangle(cornerRadius: panes.imageIsCorner ? 14 : 0)
                                .stroke(.white.opacity(0.6), lineWidth: panes.imageIsCorner ? 2 : 0)
                        )
                        .position(x: imageRect.midX, y: imageRect.midY)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .animation(.easeInOut(duration: 0.22), value: viewModel.layout)
            .animation(.easeInOut(duration: 0.22), value: viewModel.selectedImages.isEmpty)
        }
        .ignoresSafeArea()
    }
}
