//
//  VideoFrameSelectorViewStrip.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoFrameSelectorViewStrip: View {

    @Binding var fraction: Double
    let thumbnails: [UIImage]
    let stripHeight: CGFloat
    var onScrub: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let playheadX = min(max(8, CGFloat(fraction) * width), width - 8)

            ZStack(alignment: .leading) {
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
                .clipShape(RoundedRectangle(cornerRadius: 10))

                RoundedRectangle(cornerRadius: 3)
                    .stroke(.white, lineWidth: 3)
                    .frame(width: 16, height: stripHeight)
                    .offset(x: playheadX - 8)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        fraction = Double(min(max(0, value.location.x / width), 1))
                        onScrub()
                    }
            )
        }
        .frame(height: stripHeight)
    }
}
