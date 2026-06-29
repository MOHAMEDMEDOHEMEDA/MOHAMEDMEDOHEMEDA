//
//  PageDots.swift
//  Binbon
//

import SwiftUI


struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<count, id: \.self) { index in
                Group {
                    if index == current {
                        Circle().fill(.white)
                    } else {
                        Circle()
                            .fill(.clear)
                            .overlay(Circle().stroke(.white, lineWidth: 1))
                    }
                }
                .frame(width: 8, height: 8)
            }
        }
    }
}
