//
//  FullScreenReelPlayer.swift
//  Binbon
//

import SwiftUI
import AVKit

struct FullScreenReelPlayer: View {
    let player: AVPlayer
    @ObservedObject var viewModel: ReelsViewModel
    let author: String
    let caption: String
    let isActive: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geo in
            let canvasWidth = geo.size.height
            let canvasHeight = geo.size.width

            ZStack {
                Color.black

                ReelVideoPlayerView(player: player)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 16) {
                    Spacer()
                    dataBlock

                    SeekBar(
                        progress: isActive ? viewModel.progress : 0,
                        isEnabled: isActive,
                        onScrubStart: { viewModel.beginScrubbing() },
                        onScrub: { fraction in viewModel.scrub(to: fraction) },
                        onScrubEnd: { fraction in viewModel.endScrubbing(at: fraction) }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                playbackControls

                VStack {
                    HStack {
                        closeButton
                        Spacer()
                    }
                    Spacer()
                }
                .padding(20)
            }
            .frame(width: canvasWidth, height: canvasHeight)
            .rotationEffect(.degrees(90))
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .background(Color.black.ignoresSafeArea())
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.black.opacity(0.35)))
        }
        .buttonStyle(.plain)
    }

    private var playbackControls: some View {
        HStack(spacing: 36) {
            controlButton("gobackward.5", size: 24) { viewModel.skip(by: -5) }

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.togglePlayPause()
                }
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(Color.black.opacity(0.35)))
            }
            .buttonStyle(.plain)

            controlButton("goforward.5", size: 24) { viewModel.skip(by: 5) }
        }
        .shadow(color: .black.opacity(0.5), radius: 8)
    }

    private var dataBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("@\(author)")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Text(caption)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .lineLimit(2)
        .shadow(color: .black.opacity(0.6), radius: 2)
    }

    private func controlButton(_ systemName: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Circle().fill(Color.black.opacity(0.35)))
        }
        .buttonStyle(.plain)
    }
}
