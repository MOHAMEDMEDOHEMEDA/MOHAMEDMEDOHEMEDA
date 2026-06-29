//
//  PlaybackSeekBar.swift
//  Binbon
//
//  Created by Mostafa Sobaih on 04/06/2026.
//
//  Video playback progress / scrub bar. Doubles as a persistent "playing"
//  indicator: pass `isEnabled: false` to show progress without scrubbing.
//  Shared by the videos feed and the video details player.
//

import SwiftUI

struct PlaybackSeekBar: View {
    let progress: Double
    let isEnabled: Bool
    let onScrubStart: () -> Void
    let onScrub: (Double) -> Void
    let onScrubEnd: (Double) -> Void

    @State private var dragFraction: Double = 0
    @State private var isScrubbing = false

    private var displayFraction: Double {
        isScrubbing ? dragFraction : progress
    }

    var body: some View {
        GeometryReader { geometry in
            let barFrame = geometry.frame(in: .local)
            let width = barFrame.width
            let knobPosition = width * displayFraction

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(height: isScrubbing ? 4 : 2)

                Capsule()
                    .fill(Color.white)
                    .frame(width: max(16, knobPosition), height: isScrubbing ? 4 : 2)

                Circle()
                    .fill(Color.white)
                    .frame(width: isScrubbing ? 18 : 14, height: isScrubbing ? 18 : 14)
                    .offset(x: max(0, min(width - 14, knobPosition - 7)))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard isEnabled else { return }
                                let fraction = max(0, min(1, (value.location.x / width)))
                                if !isScrubbing {
                                    isScrubbing = true
                                    onScrubStart()
                                }
                                dragFraction = fraction
                                onScrub(fraction)
                            }
                            .onEnded { value in
                                guard isEnabled else { return }
                                let fraction = max(0, min(1, (value.location.x / width)))
                                dragFraction = fraction
                                onScrubEnd(fraction)
                                isScrubbing = false
                            }
                    )
            }
            .frame(height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard isEnabled else { return }
                        let fraction = max(0, min(1, (value.location.x / width)))
                        if !isScrubbing {
                            isScrubbing = true
                            onScrubStart()
                        }
                        dragFraction = fraction
                        onScrub(fraction)
                    }
                    .onEnded { value in
                        guard isEnabled else { return }
                        let fraction = max(0, min(1, (value.location.x / width)))
                        dragFraction = fraction
                        onScrubEnd(fraction)
                        isScrubbing = false
                    }
            )
        }
        .frame(height: 24)
    }
}
