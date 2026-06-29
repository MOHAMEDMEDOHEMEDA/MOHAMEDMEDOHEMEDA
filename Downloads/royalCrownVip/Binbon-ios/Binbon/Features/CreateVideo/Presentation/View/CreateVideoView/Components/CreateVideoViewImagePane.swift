//
//  CreateVideoViewImagePane.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewImagePane: View {

    let corner: Bool
    let image: UIImage?
    let zoom: CGFloat

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(zoom)
            } else {
                ZStack {
                    Color(hex: "1A1A1D")
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: corner ? 20 : 28))
                            .foregroundStyle(.white.opacity(0.5))
                        if !corner {
                            Text("add_from_gallery".localized)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .clipped()
    }
}
