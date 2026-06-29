//
//  SoundsSheetRow.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SoundsSheetRow: View {

    let track: SoundTrack
    let isSelected: Bool
    let isPlaying: Bool
    var onPreview: () -> Void = {}
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                artwork
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.appText)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.appText.opacity(0.55))
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.appText)
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        "\(track.posts) \("snd_posts".localized) · \(track.duration) · \(track.artist)"
    }

    private var artwork: some View {
        Button(action: onPreview) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColor.buttonGradient)
                    .frame(width: 56, height: 56)
                Image(systemName: isPlaying ? "pause.fill" : "music.note")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}
