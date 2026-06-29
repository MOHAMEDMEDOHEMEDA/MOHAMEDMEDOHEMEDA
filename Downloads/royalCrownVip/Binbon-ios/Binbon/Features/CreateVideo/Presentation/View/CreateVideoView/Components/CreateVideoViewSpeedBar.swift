//
//  CreateVideoViewSpeedBar.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewSpeedBar: View {

    @ObservedObject var effects: VideoEffectsState

    var body: some View {
        HStack(spacing: 8) {
            ForEach(VideoSpeed.allCases) { speed in
                let selected = effects.speed == speed
                Button { effects.speed = speed } label: {
                    Text(speed.label)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selected ? .black : .white)
                        .frame(width: 48, height: 30)
                        .background(
                            selected ? AnyShapeStyle(Color.white)
                                     : AnyShapeStyle(Color.white.opacity(0.15)),
                            in: Capsule()
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color.black.opacity(0.3), in: Capsule())
    }
}
