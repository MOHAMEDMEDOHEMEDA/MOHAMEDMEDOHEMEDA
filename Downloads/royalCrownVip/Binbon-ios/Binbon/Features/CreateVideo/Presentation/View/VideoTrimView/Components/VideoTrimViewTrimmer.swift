//
//  VideoTrimViewTrimmer.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoTrimViewTrimmer: View {
    @Binding var startFraction: Double
    @Binding var endFraction: Double
    let playhead: Double
    let thumbnails: [UIImage]
    let stripHeight: CGFloat
    let handleWidth: CGFloat

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let startX = CGFloat(startFraction) * width
            let endX = CGFloat(endFraction) * width
            let playheadX = min(max(startX + handleWidth, CGFloat(playhead) * width),
                                endX - handleWidth)

            ZStack(alignment: .leading) {
                VideoTrimViewFilmstrip(width: width,
                                       thumbnails: thumbnails,
                                       stripHeight: stripHeight)

                Color.black.opacity(0.55)
                    .frame(width: startX, height: stripHeight)
                Color.black.opacity(0.55)
                    .frame(width: max(0, width - endX), height: stripHeight)
                    .offset(x: endX)

                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white, lineWidth: 2)
                    .frame(width: max(0, endX - startX), height: stripHeight)
                    .offset(x: startX)

                Capsule()
                    .fill(.white)
                    .frame(width: 6, height: stripHeight - 8)
                    .offset(x: playheadX - 3)

                VideoTrimViewHandle(systemName: "chevron.left",
                                    leading: true,
                                    handleWidth: handleWidth,
                                    stripHeight: stripHeight)
                    .offset(x: startX)
                    .gesture(DragGesture().onChanged { value in
                        let f = Double(value.location.x / width)
                        startFraction = min(max(0, f), endFraction - 0.05)
                    })

                VideoTrimViewHandle(systemName: "chevron.right",
                                    leading: false,
                                    handleWidth: handleWidth,
                                    stripHeight: stripHeight)
                    .offset(x: endX - handleWidth)
                    .gesture(DragGesture().onChanged { value in
                        let f = Double(value.location.x / width)
                        endFraction = max(min(1, f), startFraction + 0.05)
                    })
            }
        }
        .frame(height: stripHeight)
    }
}
