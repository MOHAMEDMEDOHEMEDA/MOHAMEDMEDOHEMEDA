//
//  CreateVideoViewTrashZone.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewTrashZone: View {

    let isDraggingOverlay: Bool
    let isOverTrash: Bool

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(isOverTrash ? Color.red : Color.black.opacity(0.55))
                    .frame(width: 64, height: 64)
                Image(systemName: isOverTrash ? "trash.fill" : "trash")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(isOverTrash ? 1.25 : 1)
            .shadow(color: .black.opacity(0.4), radius: 8, y: 3)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity)
        .opacity(isDraggingOverlay ? 1 : 0)
        .offset(y: isDraggingOverlay ? 0 : 60)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isDraggingOverlay)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isOverTrash)
        .allowsHitTesting(false)
    }
}
