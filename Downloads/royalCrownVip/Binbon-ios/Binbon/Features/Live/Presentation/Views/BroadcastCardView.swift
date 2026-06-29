//
//  BroadcastCardView.swift
//  Binbon
//
//  Created by Aya Mashaly on 14/06/2026.
//

import SwiftUI

struct BroadcastCardView: View {

    let broadcast: LiveBroadcast

    var cornerRadius: CGFloat = 14
    /// When false the per-card gold border is dropped (e.g. a grid that draws a
    /// single border around the whole block instead).
    var showBorder: Bool = true

    var body: some View {
        ZStack(alignment: .top) {
            preview
            liveBadge
        }
        .aspectRatio(0.9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
               hotBadge
                   .padding(8)
           }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppColor.gold, lineWidth: showBorder ? 1 : 0)
        )
    }

    private var preview: some View {
        Color.clear
            .overlay {
                Image(broadcast.previewImageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }

    private var liveBadge: some View {
        VStack {
            HStack {
                LiveBadge()
                Spacer()
            }
            Spacer()
        }
        .padding(8)
    }

    private var hotBadge: some View {
        Group {
            if broadcast.isHot {
                Image("noto_fire")
                    .resizable()
                    .frame(width: 21, height: 21)
                    .accessibilityHidden(true)
            }
        }
    }
}

// MARK: - Pulsing live badge
private struct LiveBadge: View {

    @State private var pulse = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
                .scaleEffect(pulse ? 1.4 : 1.0)
                .animation(
                    .easeInOut(duration: 0.7).repeatForever(autoreverses: true),
                    value: pulse
                )

            Text("live_broadcast".localized)
                .font(.system(size: 11, weight: .bold))
                .lineLimit(1)
        }
        .onAppear { pulse = true }
        .accessibilityElement()
        .accessibilityLabel("live_broadcast".localized)
    }
}
