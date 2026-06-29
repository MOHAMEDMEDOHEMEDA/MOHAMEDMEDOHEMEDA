//
//  StoryAvatar.swift
//  Binbon
//
//  Created by Aya Mashaly on 17/06/2026.
//

import SwiftUI

struct StoryAvatar<RingStyle: ShapeStyle>: View {

    let assetName: String?
    var ringSize: CGFloat = 60
    var imageSize: CGFloat = 50
    var ringStyle: RingStyle
    var ringWidth: CGFloat = 2
    var fallbackGlyphSize: CGFloat = 22

    var body: some View {
        avatarImage
            .frame(width: imageSize, height: imageSize)
            .clipShape(Circle())
            .frame(width: ringSize, height: ringSize)
            .overlay {
                Circle().stroke(ringStyle, lineWidth: ringWidth)
            }
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let assetName, !assetName.isEmpty {
            Image(assetName).resizable().scaledToFill()
        } else {
            Circle().fill(AppColor.sectionSurface)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.appText.opacity(0.4))
                        .font(.system(size: fallbackGlyphSize))
                }
        }
    }
}
