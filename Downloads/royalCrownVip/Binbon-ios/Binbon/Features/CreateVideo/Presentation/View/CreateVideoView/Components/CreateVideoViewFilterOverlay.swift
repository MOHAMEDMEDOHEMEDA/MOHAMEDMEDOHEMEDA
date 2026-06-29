//
//  CreateVideoViewFilterOverlay.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewFilterOverlay: View {

    let filter: VideoFilter
    var effect: VideoEffect = .none
    let beauty: Bool

    var body: some View {
        ZStack {
            if let overlay = filter.overlay {
                Rectangle()
                    .fill(overlay.color)
                    .blendMode(overlay.blend)
                    .opacity(overlay.opacity)
            }

            effectOverlay

            if beauty {
                Rectangle()
                    .fill(.white)
                    .blendMode(.softLight)
                    .opacity(0.16)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var effectOverlay: some View {
        switch effect {
        case .vignette:
            RadialGradient(colors: [.clear, .black.opacity(0.7)],
                           center: .center, startRadius: 120, endRadius: 420)
        case .glow:
            Rectangle().fill(.white).blendMode(.softLight).opacity(0.25)
        case .comic, .posterize:
            Rectangle().fill(Color.black).blendMode(.saturation).opacity(0.4)
        default:
            EmptyView()
        }
    }
}
