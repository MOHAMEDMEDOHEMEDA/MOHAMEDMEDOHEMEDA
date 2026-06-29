//
//  VideoTrimViewProcessingCard.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoTrimViewProcessingCard: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.001).ignoresSafeArea()

            VStack(spacing: 8) {
                VideoTrimViewProcessingCircles()
                Text("processing".localized)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            }
            .frame(width: 135, height: 135)
            .background(Color.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
        }
        .transition(.opacity)
    }
}
