//
//  CreateVideoViewAddSoundButton.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct CreateVideoViewAddSoundButton: View {

    let title: String?
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "music.note")
                    .font(.system(size: 13, weight: .semibold))
                Text(title ?? "add_sound".localized)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: 200)
            .background(.black.opacity(0.4), in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
