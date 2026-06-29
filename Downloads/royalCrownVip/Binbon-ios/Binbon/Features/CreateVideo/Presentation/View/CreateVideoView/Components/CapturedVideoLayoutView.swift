//
//  CapturedVideoLayoutView.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import AVFoundation
import SwiftUI

struct CapturedVideoLayoutView: View {

    let videoURL: URL?
    let image: UIImage?
    let layout: VideoLayoutOption
    var videoVolume: Float = 1.0
    var externalPlayer: AVQueuePlayer? = nil
    var photoScale: CGFloat = 1
    var photoRotation: Angle = .zero

    var body: some View {
        GeometryReader { geo in
            let panes = layout.panes(for: geo.size)
            ZStack(alignment: .topLeading) {
                Color.black

                if let videoURL {
                    Group {
                        if let externalPlayer {
                            PlayerLayerView(player: externalPlayer)
                        } else {
                            LoopingPlayer(url: videoURL, volume: videoVolume)
                        }
                    }
                    .frame(width: panes.camera.width, height: panes.camera.height)
                    .clipped()
                    .position(x: panes.camera.midX, y: panes.camera.midY)
                } else if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(photoScale)
                        .rotationEffect(photoRotation)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }

                if let imageRect = panes.image, let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
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
        }
        .ignoresSafeArea()
    }
}
