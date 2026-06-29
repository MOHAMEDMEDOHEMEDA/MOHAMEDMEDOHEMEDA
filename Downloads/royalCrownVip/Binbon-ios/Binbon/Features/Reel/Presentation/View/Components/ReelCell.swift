//
//  ReelCell.swift
//  Binbon
//
//  Created by Mrwan hany on 17/06/2026.
//

import SwiftUI

 struct ReelCell: View {
    let reel: ReelModel
    @ObservedObject var viewModel: ReelsViewModel
    @Environment(\.router) private var router

    private var isActive: Bool { viewModel.currentReelId == reel.id }
    private var isLiked: Bool { viewModel.isLiked(reel.id) }
    private var isBookmarked: Bool { viewModel.isBookmarked(reel.id) }

    private let cellSpace = "reelCell"

    @State private var showComments = false
    @State private var showShareSheet = false
    @State private var showSendSheet = false
    @State private var showSaveSheet = false
    @State private var showFullScreen = false
    @State private var showContentSupport = false
    @State private var likedBurstID: UUID?
    @State private var flyingHearts: [FlyingHeart] = []

    @ObservedObject private var chrome = ReelChromeState.shared
    @State private var hideTask: Task<Void, Never>?

    private var shareURL: URL {
        URL(string: "https://binbon.app/reel/\(reel.id)") ?? URL(string: "https://binbon.app")!
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
                        viewModel.likeFromDoubleTap(reelID: reel.id)
                    }
                    .onTapGesture {
                        guard isActive else { return }
                        toggleChrome()
                    }

                ReelVideoPlayerView(player: viewModel.player(for: reel))
                    .allowsHitTesting(false)
                    .frame(
                        width: showComments ? geo.size.width * 0.5 : geo.size.width,
                        height: showComments ? geo.size.height * 0.40 : geo.size.height
                    )
                    .clipShape(RoundedRectangle(cornerRadius: showComments ? 10 : 0, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: showComments ? .top : .center)
                    .padding(.top, showComments ? 24 : 0)
                    .animation(.easeInOut(duration: 0.25), value: showComments)

                Group {
                    VStack {
                        rightControls
                            .padding(.trailing, 16)
                            .padding(.top, 170)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    centerPlaybackControls

                    VStack(alignment: .leading, spacing: 16) {
                        Spacer()
                        controlWidget
                            .offset(y: 100) // nudge the action rail down on its own, without shifting the widgets below

                        HStack {
                            Spacer()
                            ContentSupportWidget(
                                onSupport: { showContentSupport = true },
                                onPromotion: { router.navigate(.promoteSettings) }
                            )
                        }

                        userWidget

                        SeekBar(
                            progress: isActive ? viewModel.progress : 0,
                            isEnabled: isActive,
                            onScrubStart: { viewModel.beginScrubbing() },
                            onScrub: { fraction in viewModel.scrub(to: fraction) },
                            onScrubEnd: { fraction in viewModel.endScrubbing(at: fraction) }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 130)
                }
                .opacity(chrome.chromeVisible && !showComments ? 1 : 0)
                .allowsHitTesting(chrome.chromeVisible && !showComments)

                FlyingHeartsLayer(hearts: flyingHearts, target: center)
                    .allowsHitTesting(false)

                if let likedBurstID {
                    LikedHeartsBurst()
                        .id(likedBurstID)
                        .allowsHitTesting(false)
                }
            }
            .coordinateSpace(name: cellSpace)
            .clipped()
        }
        .onChange(of: isActive) { _, active in
            if active {
                scheduleAutoHide()
                flashLikedHeart()
            } else {
                hideTask?.cancel()
            }
        }
        .onChange(of: viewModel.isPaused) { _, paused in
            guard isActive, !showFullScreen else { return }
            if paused {
                hideTask?.cancel()
                withAnimation(.easeInOut(duration: 0.3)) {
                    chrome.chromeVisible = true
                }
            } else {
                scheduleAutoHide()
            }
        }
        .onAppear {
            if isActive {
                scheduleAutoHide()
                flashLikedHeart()
            }
        }
        .onDisappear {
            hideTask?.cancel()
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
        .sheet(isPresented: $showSendSheet) {
            ReelSendToSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showContentSupport) {
            ContentSupportSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
        .fullScreenCover(isPresented: $showFullScreen, onDismiss: {
            guard isActive else { return }
            viewModel.exitFullScreen()
        }) {
            FullScreenReelPlayer(
                player: viewModel.player(for: reel),
                viewModel: viewModel,
                author: reel.author,
                caption: reel.caption,
                isActive: isActive
            )
        }
        .onChange(of: showFullScreen) { _, showing in
            guard isActive, showing else { return }
            viewModel.enterFullScreen()
        }
    }

    private func toggleChrome() {
        withAnimation(.easeInOut(duration: 0.3)) {
            chrome.chromeVisible.toggle()
        }
        if chrome.chromeVisible {
            scheduleAutoHide()
        } else {
            hideTask?.cancel()
        }
    }

    private func hideChromeNow() {
        hideTask?.cancel()
        withAnimation(.easeInOut(duration: 0.3)) {
            chrome.chromeVisible = false
        }
    }

    private func scheduleAutoHide() {
        hideTask?.cancel()
        hideTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard !Task.isCancelled, !viewModel.isPaused else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                chrome.chromeVisible = false
            }
        }
    }

    private func spawnHeart(at point: CGPoint) {
        let heart = FlyingHeart(id: UUID(), start: point)
        flyingHearts.append(heart)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            flyingHearts.removeAll { $0.id == heart.id }
        }
    }

    private func flashLikedHeart() {
        guard isLiked else { return }
        let id = UUID()
        likedBurstID = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if likedBurstID == id { likedBurstID = nil }
        }
    }

    private var centerPlaybackControls: some View {
        HStack(spacing: 28) {
            circleControl("gobackward.5", size: 22) {
                viewModel.skip(by: -5)
            }

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

            circleControl("goforward.5", size: 22) {
                viewModel.skip(by: 5)
            }
        }
        .shadow(color: .black.opacity(0.5), radius: 8)
    }

    private var rightControls: some View {
        VStack(spacing: 18) {
            circleControl(viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill") {
                viewModel.toggleMute()
            }

            circleControl("arrow.up.left.and.arrow.down.right") {
                showFullScreen = true
            }

            circleControl("eye.fill") {
                hideChromeNow()
            }
        }
    }

    private func circleControl(_ systemName: String, size: CGFloat = 17, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.black.opacity(0.35)))
        }
        .buttonStyle(.plain)
    }

    private var userWidget: some View {
        HStack(spacing: 10) {
            ImageView("https://picsum.photos/200/300")
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay { Circle().stroke(Color.appGold, lineWidth: 2) }

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Text("@\(reel.author)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.appText)
                    Spacer()

                    if !reel.date.isEmpty {
                        Text(reel.date)
                            .font(.caption)
                            .foregroundStyle(.appText.opacity(0.7))
                    }
                }

                Text(reel.caption)
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.8))

                Text("#Lorem #Lorem #Lorem ")
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.6))
            }
            .lineLimit(1)
            .shadow(color: .black.opacity(0.6), radius: 2)
        }
    }

    private var controlWidget: some View {
        VStack(alignment: .center, spacing: 14) {
            ReelProfileButton(avatarURL: "https://picsum.photos/200/300") {
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 12)

            ReelLikeButton(isLiked: isLiked, count: viewModel.likeCount(for: reel)) {
                viewModel.toggleLike(for: reel.id)
            }
            .padding(.horizontal, 4)

            Button {
                showComments = true
            } label: {
                Label("\(reel.likes)", image: "reels-comments")
                    .labelStyle(.vertical)
            }
            .padding(.horizontal, 4)
            .contentShape(Rectangle())

            ReelBookmarkButton(isBookmarked: isBookmarked, count: reel.likes) {
                viewModel.toggleBookmark(for: reel.id)
                showSaveSheet = true
            }
            .padding(.horizontal, 4)

            Button {
                showShareSheet = true
            } label: {
                Label {
                    Text("\(reel.likes)")
                } icon: {
                    Image("reels-share")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24.35, height: 19.44)
                }
                .labelStyle(.vertical)
            }
            .padding(.horizontal, 4)
            .contentShape(Rectangle())

            Button {
                showSendSheet = true
            } label: {
                Label {
                    Text("\(reel.likes)")
                } icon: {
                    Image(systemName: "paperplane")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24.02, height: 22)
                }
                .labelStyle(.vertical)
            }
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.appText)
        .padding(.bottom, 40)
    }
}

