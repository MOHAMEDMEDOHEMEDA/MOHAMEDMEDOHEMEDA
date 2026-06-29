//
//  ReelsViewModel.swift
//  Binbon
//
//  Created by Mostafa Sobaih on 04/06/2026.
//

import SwiftUI
import AVKit

struct VideosView: View {
    @StateObject private var viewModel = VideosViewModel()
    @Environment(\.router) private var router
    @State private var selectedVideo: VideoModel?

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .ignoresSafeArea(.all)
            .persistentSystemOverlays(.hidden) // Prevents safe area recalculation

            .task {
                if case .idle = viewModel.state {
                    viewModel.load()
                }
            }
            .padding(.top,120)
            .appBackground()
            .fullScreenCover(item: $selectedVideo) { video in
                VideoDetailsView(video: video, viewModel: VideosViewModel())
                    // Covers don't inherit the global layout direction; re-apply it.
                    .localizer()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let videos):
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 18) {
                    ForEach(videos) { video in
                        VideoCardView(video: video, viewModel: viewModel) {
                            selectedVideo = video
                        }
                    }
                }
                .padding(.bottom, 120)
            }

        case .failed(let message):
            ContentUnavailableView {
                Label("couldnt_load_videos".localized, systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("retry".localized) {
                    viewModel.load()
                }
                .tint(.appGold)
            }
        }
    }
}

private struct VideoCardView: View {
    let video: VideoModel
    @ObservedObject var viewModel: VideosViewModel
    let onSelect: () -> Void
    @State private var isExpanded: Bool = false
    @State private var isTitleExpandable: Bool = false
    @State private var showControls: Bool = true
    @State private var hideWorkItem: DispatchWorkItem?
    @State private var captionsOn: Bool = false
    @State private var quality: VideoQuality = .auto

    private let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]

    private var isActive: Bool { viewModel.currentVideoId == video.id }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                // Player / thumbnail
                Group {
                    if isActive, let player = viewModel.player(for: video) {
                        VideoPlayerView(player: player)
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .clipped()
                            .allowsHitTesting(false)
                    } else {
                        ImageView(video.thumbnailURL)
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .clipped()
                            // YouTube-style duration badge while the thumbnail shows.
                            .overlay(alignment: .bottomTrailing) { durationBadge }
                    }
                }

                // Dim scrim behind the controls.
                if isActive && showControls {
                    Color.black.opacity(0.3)
                }

                // Top cluster (settings / CC / quality / mute) + center transport.
                if isActive && showControls {
                    VStack(spacing: 0) {
                        topControls
                        Spacer()
                        centerTransport
                        Spacer()
                    }
                }

                // Bottom info row (with controls) + persistent progress bar.
                if isActive {
                    VStack(spacing: 6) {
                        if showControls { bottomInfo }
                        PlaybackSeekBar(
                            progress: viewModel.progress,
                            isEnabled: showControls,
                            onScrubStart: { viewModel.beginScrubbing() },
                            onScrub: { fraction in viewModel.scrub(to: fraction) },
                            onScrubEnd: { fraction in viewModel.endScrubbing(at: fraction) }
                        )
                        // Keep the scrubber direction fixed regardless of locale.
                        .environment(\.layoutDirection, .leftToRight)
                    }
                    .padding(.bottom, showControls ? 8 : 4)
                }
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture {
                // Not playing yet → start inline playback.
                // Already playing → open the video details screen.
                if isActive {
                    onSelect()
                } else {
                    viewModel.activateVideo(video.id)
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    showControls = true
                    scheduleHide()
                } else {
                    hideWorkItem?.cancel()
                }
            }
            .onChange(of: viewModel.isPaused) { _, paused in
                guard isActive else { return }
                if paused {
                    // Keep the controls visible while paused.
                    hideWorkItem?.cancel()
                    withAnimation(.easeInOut(duration: 0.25)) { showControls = true }
                } else {
                    scheduleHide()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                // Title + hashtags with the ⋮ menu on the trailing side.
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(video.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(isExpanded ? 10 : 2)
                            .multilineTextAlignment(.leading)
                            .background(
                                // Detect real truncation: compare the displayed (2-line)
                                // height against the full text height at the same width.
                                GeometryReader { limited in
                                    Text(video.title)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(width: limited.size.width, alignment: .topLeading)
                                        .background(
                                            GeometryReader { full in
                                                Color.clear
                                                    .onAppear {
                                                        isTitleExpandable = full.size.height > limited.size.height + 1
                                                    }
                                                    .onChange(of: full.size.height) { _, h in
                                                        isTitleExpandable = h > limited.size.height + 1
                                                    }
                                            }
                                        )
                                        .hidden()
                                }
                            )

                        Text(video.hashtags)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(90))
                            .frame(width: 24, height: 24)
                    }
                }

                HStack(spacing: 4) {
                    Text(video.views)
                    Text("•")
                    Text(video.age)

                    if isTitleExpandable {
                        Text("more".localized)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    Spacer()
                }
                .font(.caption)
                .foregroundStyle(.white)

                // Channel row: avatar + name + subscriber count + Subscribe.
                HStack(spacing: 10) {
                    ImageView(video.authorAvatarURL)
                        .frame(width: 38, height: 38)
                        .clipShape(Circle())

                    Text(video.authorName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

//                    Spacer()
//
//                    Text("735 K")
//                        .font(.caption)
//                        .foregroundStyle(.white.opacity(0.75))
//
//                    Button(action: {}) {
//                        Text("subscribe".localized)
//                            .font(.caption.weight(.semibold))
//                            .foregroundStyle(.white)
//                            .padding(.horizontal, 14)
//                            .padding(.vertical, 6)
//                            .background(AppColor.videoSubscribeFill, in: Capsule())
//                    }
//                    .buttonStyle(.plain)
                }
            }
            .padding(12)
        }
        // Whole cell is tappable to open the video details screen.
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }

    private var durationBadge: some View {
        Text(video.duration)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
            .padding(8)
    }

    // MARK: - Player controls

    /// Top-left feature cluster (settings, captions, quality, HD badge) + mute.
    private var topControls: some View {
        HStack(spacing: 16) {
            settingsMenu

            Button {
                captionsOn.toggle()
                scheduleHide()
            } label: {
                Image(systemName: captionsOn ? "captions.bubble.fill" : "captions.bubble")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            qualityMenu
            qualityBadge

            Spacer()

            Button {
                viewModel.toggleMute()
                scheduleHide()
            } label: {
                Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
    }

    /// Settings menu — playback speed.
    private var settingsMenu: some View {
        Menu {
            Section("playback_speed".localized) {
                ForEach(speeds, id: \.self) { rate in
                    Button {
                        viewModel.setPlaybackRate(rate)
                        scheduleHide()
                    } label: {
                        HStack {
                            Text(speedLabel(rate))
                            if viewModel.playbackRate == rate { Image(systemName: "checkmark") }
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    /// Quality menu — Auto / 1080p / 720p / 480p (mock until real renditions exist).
    private var qualityMenu: some View {
        Menu {
            ForEach(VideoQuality.allCases) { option in
                Button {
                    quality = option
                    scheduleHide()
                } label: {
                    HStack {
                        Text(option.label)
                        if quality == option { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            Image(systemName: "wifi")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var qualityBadge: some View {
        Text(quality.badge)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.3), in: Capsule())
    }

    /// Center transport: 10-second skips around play / pause.
    private var centerTransport: some View {
        HStack(spacing: 36) {
            Button {
                viewModel.skip(by: -10)
                scheduleHide()
            } label: {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Button {
                viewModel.togglePlayPause()
                scheduleHide()
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(Color.black.opacity(0.50))
                    .clipShape(Circle())
            }

            Button {
                viewModel.skip(by: 10)
                scheduleHide()
            } label: {
                Image(systemName: "goforward.10")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    /// Bottom row: time read-out + open-details chevron + fullscreen.
    private var bottomInfo: some View {
        HStack(spacing: 10) {
            Text("\(viewModel.currentTimeText) / \(currentVideoTotalDuration)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)

            Button(action: onSelect) {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()

            Button(action: onSelect) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 14)
        .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
    }

    private func speedLabel(_ rate: Float) -> String {
        rate.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(rate))x"
            : String(format: "%.1fx", rate)
    }

    /// Hides the player controls after 2 seconds — but only while the video
    /// is playing. When paused, the controls stay visible.
    private func scheduleHide() {
        hideWorkItem?.cancel()
        guard !viewModel.isPaused else { return }
        let work = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.25)) {
                showControls = false
            }
        }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: work)
    }

    private var currentVideoTotalDuration: String {
        guard let id = viewModel.currentVideoId else { return "00:00" }
        if case .loaded(let videos) = viewModel.state {
            return videos.first(where: { $0.id == id })?.duration ?? "00:00"
        }
        return "00:00"
    }
}


struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    var videoGravity: AVLayerVideoGravity = .resizeAspectFill

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = videoGravity
        controller.view.backgroundColor = .black
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
        uiViewController.videoGravity = videoGravity
    }
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

struct VideosView_Previews: PreviewProvider {
    static var previews: some View {
        VideosView()
    }
}

