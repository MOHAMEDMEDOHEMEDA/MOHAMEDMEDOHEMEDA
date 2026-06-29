//
//  CreateVideoViewDurationOptions.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import Combine
import SwiftUI

struct CreateVideoViewDurationOptions: View {

    @ObservedObject var camera: CameraManager
    let durations: [(String, Int)]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(Array(durations.enumerated()), id: \.offset) { _, item in
                let selected = camera.maxSeconds == item.1
                Button { camera.maxSeconds = item.1 } label: {
                    Text(item.0)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(selected ? .black : .white)
                        .padding(.horizontal, selected ? 12 : 4)
                        .padding(.vertical, 4)
                        .background(
                            selected ? AnyShapeStyle(Color.white) : AnyShapeStyle(Color.clear),
                            in: Capsule()
                        )
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
