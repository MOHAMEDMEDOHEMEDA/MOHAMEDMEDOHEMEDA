//
//  VideoTrimViewHandle.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoTrimViewHandle: View {
    let systemName: String
    let leading: Bool
    let handleWidth: CGFloat
    let stripHeight: CGFloat

    var body: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: leading ? 15 : 0,
            bottomLeadingRadius: leading ? 15 : 0,
            bottomTrailingRadius: leading ? 0 : 15,
            topTrailingRadius: leading ? 0 : 15
        )
        .fill(.white)
        .frame(width: handleWidth, height: stripHeight)
        .overlay(
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: "3A3A3C"))
        )
    }
}
