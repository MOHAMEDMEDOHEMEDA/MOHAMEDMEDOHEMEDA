//
//  VideoEditorVolumePanel.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct VideoEditorVolumePanel: View {

    @Binding var videoVolume: Double
    @Binding var soundVolume: Double
    let hasSound: Bool
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("volume".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button(action: onClose) { Image(systemName: "xmark").foregroundStyle(.white) }
                    .buttonStyle(.plain)
            }

            slider(icon: "video.fill", title: "video_volume".localized, value: $videoVolume)
            slider(icon: "music.note", title: "sound_volume".localized, value: $soundVolume,
                   disabled: !hasSound)
        }
        .padding(20)
        .background(.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private func slider(icon: String, title: String, value: Binding<Double>, disabled: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(.white)
                Text(title).font(.system(size: 13)).foregroundStyle(.white)
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            Slider(value: value, in: 0...1)
                .disabled(disabled)
                .opacity(disabled ? 0.4 : 1)
        }
    }
}
