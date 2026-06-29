//
//  ShortCell.swift
//  Binbon
//
//  A single short in the feed. Same shape as a reel, mirrored: the engagement
//  rail sits on the trailing edge, the top row carries only a views pill (leading)
//  and a mute toggle (trailing), the caption block sits bottom-leading above the
//  scrub bar.
//

import SwiftUI

struct ShortCell: View {
    let short: ShortModel
    @ObservedObject var viewModel: ShortsViewModel

    private var isActive: Bool { viewModel.currentShortId == short.id }
    private var isLiked: Bool { viewModel.isLiked(short.id) }

    /// Clears the home search/tabs chrome that overlays the top of the feed.
    private let topInset: CGFloat = 180

    private let cellSpace = "shortCell"

    @State private var showComments = false
    @State private var showSaveSheet = false
    @State private var showShareSheet = false
    @State private var flyingHearts: [FlyingHeart] = []

    private var shareURL: URL {
        URL(string: "https://binbon.app/short/\(short.id)") ?? URL(string: "https://binbon.app")!
    }

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                Color.black
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2, coordinateSpace: .named(cellSpace)) { location in
                        guard isActive else { return }
                        spawnHeart(at: location)
                        viewModel.likeFromDoubleTap(shortID: short.id)
                    }
                    .onTapGesture {
                        guard isActive else { return }
                        withAnimation(.easeInOut(duration: 0.15)) { viewModel.togglePlayPause() }
                    }

                ShortVideoPlayerView(player: viewModel.player(for: short))
                    .allowsHitTesting(false)
                    .ignoresSafeArea()

                topControls
                rail
                captionAndSeekBar

                if viewModel.isPaused && isActive {
                    playButton
                }

                FlyingHeartsLayer(hearts: flyingHearts, target: center)
                    .allowsHitTesting(false)
            }
            .coordinateSpace(name: cellSpace)
            .clipped()
        }
        .sheet(isPresented: $showComments) {
            RichCommentsView()
                .presentationDetents([.fraction(0.6)])
                .presentationCornerRadius(20)
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.6)))
        }
        .sheet(isPresented: $showSaveSheet) {
            SaveToCollectionSheet()
                .presentationDetents([.fraction(0.45), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationBackground(AppColor.cardBackground)
        }
        .systemShareSheet(isPresented: $showShareSheet, items: [shareURL])
    }

    private func spawnHeart(at point: CGPoint) {
        let heart = FlyingHeart(id: UUID(), start: point)
        flyingHearts.append(heart)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            flyingHearts.removeAll { $0.id == heart.id }
        }
    }

    // MARK: - Top controls (views • mute)

    private var topControls: some View {
        VStack {
            HStack(alignment: .top) {
                viewsPill
                Spacer()
                muteButton
            }
            .padding(.horizontal, 16)
            .padding(.top, topInset)
            Spacer()
        }
    }

    private var viewsPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "play.fill")
                .font(.system(size: 11, weight: .bold))
            Text("shorts_views".localizedFormat(short.viewsText))
                .font(.system(size: 13, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.black.opacity(0.4))
        )
    }

    private var muteButton: some View {
        Button {
            viewModel.toggleMute()
        } label: {
            Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.black.opacity(0.4)))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Center play button

    private var playButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { viewModel.togglePlayPause() }
        } label: {
            Image(systemName: "play.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 96, height: 96)
                .background(Circle().fill(Color.white.opacity(0.18)))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Engagement rail (trailing)

    private var rail: some View {
        VStack {
            Spacer()
            ShortsRail(
                short: short,
                isLiked: isLiked,
                onLike: { viewModel.toggleLike(for: short.id) },
                onComment: { showComments = true },
                onSave: { showSaveSheet = true },
                onShare: { showShareSheet = true }
            )
            Spacer().frame(height: 150)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 12)
    }

    // MARK: - Caption + scrub bar (leading)

    private var captionAndSeekBar: some View {
        VStack(alignment: .leading, spacing: 14) {
            Spacer()
            captionBlock
                .padding(.trailing, 80) // keep clear of the rail
            ShortsSeekBar(
                progress: isActive ? viewModel.progress : 0,
                isEnabled: isActive,
                onScrubStart: { viewModel.beginScrubbing() },
                onScrub: { viewModel.scrub(to: $0) },
                onScrubEnd: { viewModel.endScrubbing(at: $0) }
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 130)
    }

    private var captionBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("@\(short.author)")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)

            Text(short.caption)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(short.tags)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appGold)

            HStack(spacing: 8) {
                ImageView(short.soundAvatarURL, placeholder: Image(systemName: "music.note"))
                    .frame(width: 26, height: 26)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 1))
                Text("\(short.soundTitle) · \(short.soundArtist)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(.top, 2)
        }
        .shadow(color: .black.opacity(0.5), radius: 4)
    }
}
