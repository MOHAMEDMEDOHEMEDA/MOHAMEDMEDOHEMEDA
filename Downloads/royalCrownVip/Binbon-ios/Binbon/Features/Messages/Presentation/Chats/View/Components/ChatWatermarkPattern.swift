//
//  ChatWatermarkPattern.swift
//  Binbon
//

import SwiftUI

struct ChatWatermarkPattern: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                AppColor.backgroundGradient
                Image("chat_pattern")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        }
        .ignoresSafeArea()
    }
}
