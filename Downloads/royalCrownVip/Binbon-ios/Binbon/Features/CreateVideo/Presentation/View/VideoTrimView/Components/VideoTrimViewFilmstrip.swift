//
//  VideoTrimViewFilmstrip.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoTrimViewFilmstrip: View {
    let width: CGFloat
    let thumbnails: [UIImage]
    let stripHeight: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            if thumbnails.isEmpty {
                Color(hex: "2A2A2E").frame(width: width, height: stripHeight)
            } else {
                ForEach(Array(thumbnails.enumerated()), id: \.offset) { _, img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width / CGFloat(thumbnails.count), height: stripHeight)
                        .clipped()
                }
            }
        }
        .frame(width: width, height: stripHeight)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
