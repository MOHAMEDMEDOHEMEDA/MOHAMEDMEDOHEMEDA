//
//  CreateVideoViewModeSelector.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import SwiftUI

struct CreateVideoViewModeSelector: View {

    @Binding var mode: CreateVideoViewModel.CaptureMode

    private var modes: [CreateVideoViewModel.CaptureMode] { CreateVideoViewModel.CaptureMode.allCases }

    var body: some View {
        HStack(spacing: 22) {
            ForEach(modes) { item in
                let selected = item == mode
                Text(item.title)
                    .font(.system(size: 13, weight: selected ? .bold : .medium))
                    .foregroundStyle(selected ? .white : .white.opacity(0.5))
                    .scaleEffect(selected ? 1.05 : 1)
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { mode = item } }
            }
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    guard let index = modes.firstIndex(of: mode) else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if value.translation.width < -24, index < modes.count - 1 {
                            mode = modes[index + 1]
                        } else if value.translation.width > 24, index > 0 {
                            mode = modes[index - 1]
                        }
                    }
                }
        )
    }
}
