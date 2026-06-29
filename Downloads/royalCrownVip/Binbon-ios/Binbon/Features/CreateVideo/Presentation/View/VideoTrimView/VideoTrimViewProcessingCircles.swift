//
//  VideoTrimViewProcessingCircles.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoTrimViewProcessingCircles: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "E14554"))
                .frame(width: 26, height: 26)
                .offset(x: animate ? -13 : -5)
            Circle()
                .fill(Color(hex: "8E4C9E"))
                .frame(width: 26, height: 26)
                .offset(x: animate ? 13 : 5)
                .blendMode(.screen)
        }
        .compositingGroup()
        .frame(width: 53, height: 31)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.65).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
