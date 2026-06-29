//
//  StoryEditorCanvas.swift
//  Binbon
//

import SwiftUI

struct StoryEditorCanvas: View {

    let draft: StoryDraft

    var body: some View {
        GeometryReader { geo in
            let cardSize = StoryEditorLayout.cardSize(in: geo.size)

            ZStack {
                LinearGradient(
                    colors: [Color(hex: "2B1248"), Color(hex: "120A22")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ZStack {
                    Color.black

                    if let url = draft.mediaVideoURL {
                        LoopingPlayer(url: url, volume: 1)
                            .frame(width: cardSize.width, height: cardSize.height)
                            .clipped()
                    } else if let image = draft.mediaImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(draft.photoScale)
                            .rotationEffect(draft.photoRotation)
                            .frame(width: cardSize.width, height: cardSize.height)
                            .clipped()
                    }

                    CreateVideoViewFilterOverlay(filter: draft.filter, beauty: false)
                }
                .frame(width: cardSize.width, height: cardSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
    }
}
