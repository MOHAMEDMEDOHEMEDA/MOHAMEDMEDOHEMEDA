//
//  VideoDetailsView.swift
//  Binbon
//
//  Created by Mostafa Sobaih on 04/06/2026.
//

import SwiftUI
import AVKit

struct VideoDetailsView: View {
    let video: VideoModel
    @StateObject private var viewModel: VideosViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isFullScreen: Bool = false
    @State private var showMenuSheet: Bool = false
    @State private var showControls: Bool = true
    @State private var hideWorkItem: DispatchWorkItem?
    @State private var isLiked: Bool = false
    @State private var isDisliked: Bool = false
    @State private var isSubscribed: Bool = false
    @State private var isReported: Bool = false
    @State private var likeCount: Int = 3600
    @State private var dislikeCount: Int = 15
    @State private var commentCount: Int = 20
    @State private var isTitleTruncated: Bool = false

    init(video: VideoModel, viewModel: VideosViewModel) {
        self.video = video
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var topSafeAreaInset: CGFloat {
        UIApplication.shared.keyWindowSafeAreaInsets.top
    }

    // TODO: Mock suggestions — replace with a Repo/Service fetch once the
    // related-videos endpoint exists.
    private let suggestedVideos: [VideoModel] = [
        VideoModel(id: "s1", thumbnailURL: "https://picsum.photos/seed/sug1/800/450", videoURL: nil,
                   duration: "12:04", title: "Lorem Ipsum is simply dummy text of the printing",
                   hashtags: "#Lorem", views: "1.2M views", age: "2 days ago",
                   authorName: "Channel Name", authorAvatarURL: "https://picsum.photos/seed/sugav1/100"),
        VideoModel(id: "s2", thumbnailURL: "https://picsum.photos/seed/sug2/800/450", videoURL: nil,
                   duration: "07:32", title: "Another suggested video title goes right here",
                   hashtags: "#Lorem", views: "845K views", age: "5 days ago",
                   authorName: "Creator Studio", authorAvatarURL: "https://picsum.photos/seed/sugav2/100"),
        VideoModel(id: "s3", thumbnailURL: "https://picsum.photos/seed/sug3/800/450", videoURL: nil,
                   duration: "21:18", title: "Lorem ipsum dolor sit amet consectetur",
                   hashtags: "#Lorem", views: "98K views", age: "1 week ago",
                   authorName: "Daily Clips", authorAvatarURL: "https://picsum.photos/seed/sugav3/100")
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 0) {
                        // Video Player Section
                        ZStack {
                            if let player = viewModel.player(for: video) {
                                VideoPlayerView(player: player)
                                    .frame(height: 300 + topSafeAreaInset)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black)
                                    .clipped()
                                    .allowsHitTesting(false)
                            }

                            // Full-area tap layer to toggle the controls.
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { toggleControls() }

                            // Top bar is always present so the dismiss arrow
                            // never disappears; mute/menu hide with the controls.
                            playerTopBar

                            if showControls {
                                // Centered independently of the top bar.
                                playerPlaybackControls
                                playerFullScreenButton
                            }

                            // Persistent playback indicator pinned to the
                            // player's bottom edge — visible even after the
                            // controls auto-hide; scrubs only while they show.
                            if viewModel.player(for: video) != nil {
                                playerProgressBar
                            }
                        }
                        .frame(height: 300 + topSafeAreaInset)
                        .frame(maxWidth: .infinity)

                        // Info, comments and suggested share one continuous brand panel.
                        VStack(spacing: 0) {
                        // Info Section
                        VStack(alignment: .leading, spacing: 14) {
                            // Title + hashtags + stats with the vertical menu
                            HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(video.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(AppColor.videoInk)
                                        .lineLimit(2)
                                        .background(
                                            // Detect real truncation against the full text height.
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
                                                                    isTitleTruncated = full.size.height > limited.size.height + 1
                                                                }
                                                                .onChange(of: full.size.height) { _, h in
                                                                    isTitleTruncated = h > limited.size.height + 1
                                                                }
                                                        }
                                                    )
                                                    .hidden()
                                            }
                                        )

                                    Text(video.hashtags)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(AppColor.videoInk)
                                        .lineLimit(1)

                                    HStack(spacing: 8) {
                                        Text(video.views)
                                        Text(video.age)
                                        if isTitleTruncated {
                                            Text("more".localized)
                                                .foregroundStyle(AppColor.videoInk)
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundStyle(AppColor.videoInkMuted)
                                }

                                Spacer(minLength: 8)

                                Button {
                                    showMenuSheet = true
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(AppColor.videoInk)
                                        .rotationEffect(.degrees(90))
                                        .frame(width: 24, height: 24)
                                }
                            }

                            // Author row with Subscribe
                            HStack(spacing: 12) {
                                ImageView(video.authorAvatarURL)
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(video.authorName)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(AppColor.videoInk)

                                        Spacer()

                                        Text("735 K")
                                            .font(.caption)
                                            .foregroundStyle(AppColor.videoInkMuted)
                                    }

                                    Button {
                                        isSubscribed.toggle()
                                    } label: {
                                        Text(isSubscribed ? "subscribed".localized : "subscribe".localized)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(isSubscribed ? AppColor.videoInk : .white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 7)
                                            .background(isSubscribed ? AppColor.videoActionChip : AppColor.videoSubscribeFill)
                                            .clipShape(Capsule())
                                    }
                                }
                            }

                            // Action pills
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    // Combined like / dislike
                                    HStack(spacing: 16) {
                                        Button {
                                            toggleLike()
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text(formatCount(likeCount))
                                                Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                            }
                                        }
                                        .buttonStyle(.plain)

                                        Button {
                                            toggleDislike()
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text(formatCount(dislikeCount))
                                                Image(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppColor.videoInk)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(AppColor.videoActionChip)
                                    .clipShape(Capsule())

                                    actionPill(text: "\(commentCount)", icon: "bubble.left.fill", iconFirst: true) {
                                        commentCount += 1
                                    }
                                    actionPill(text: "share".localized, icon: "paperplane.fill", iconFirst: true) {}
                                    actionPill(
                                        text: "report".localized,
                                        icon: isReported ? "flag.fill" : "flag",
                                        iconFirst: true,
                                        isSelected: isReported
                                    ) {
                                        isReported.toggle()
                                    }
                                }
                            }
                        }
                        .padding(12)

                        // Comments Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("comments".localized)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColor.videoInk)
                                .padding(.horizontal, 12)
                                .padding(.top, 16)

                            // Sample Comment
                            HStack(alignment: .top, spacing: 12) {
                                ImageView("https://picsum.photos/seed/commenter/100")
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Ali Salah")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppColor.videoInk)

                                    Text("Lorem Ipsum is simply dummy 😍")
                                        .font(.subheadline)
                                        .foregroundStyle(AppColor.videoInk)

                                    HStack(spacing: 10) {
                                        Image(systemName: "hand.thumbsdown")
                                        Text("20")
                                            .fontWeight(.semibold)
                                        Image(systemName: "heart")

                                        Spacer()

                                        Text("4day")
                                        Text("reply".localized)
                                    }
                                    .font(.caption)
                                    .foregroundStyle(AppColor.videoInkMuted)
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Hairline between the comments and suggested sections.
                        Rectangle()
                            .fill(AppColor.videoMenuDivider)
                            .frame(height: 0.5)

                        // Suggested Videos Section — YouTube-style cards.
                        VStack(alignment: .leading, spacing: 16) {
                            Text("suggested".localized)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColor.videoInk)

                            ForEach(suggestedVideos) { item in
                                suggestedCard(item)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(AppColor.videoInfoPanel)
                    }
                }
                // Let the player fill behind the status bar / Dynamic Island.
                .ignoresSafeArea(edges: .top)
            }
            .appBackground()
        }
        .sheet(isPresented: $showMenuSheet) {
            VideoActionMenuSheet()
                // Sheets don't inherit the global layout direction; re-apply it.
                .localizer()
        }
        .onAppear {
            viewModel.activateVideo(video.id, autoplay: false)
            scheduleHide()
        }
        .onChange(of: viewModel.isPaused) { _, paused in
            if paused {
                // Keep the controls visible while paused.
                hideWorkItem?.cancel()
                withAnimation(.easeInOut(duration: 0.25)) { showControls = true }
            } else {
                scheduleHide()
            }
        }
        .onDisappear { hideWorkItem?.cancel() }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenVideoPlayer(video: video, viewModel: viewModel)
                // Covers don't inherit the global layout direction; re-apply it.
                .localizer()
        }
    }
    
    private func actionPill(
        text: String,
        icon: String,
        iconFirst: Bool,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if iconFirst {
                    Image(systemName: icon)
                    Text(text)
                } else {
                    Text(text)
                    Image(systemName: icon)
                }
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppColor.videoInk)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AppColor.videoActionChipSelected : AppColor.videoActionChip)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func toggleLike() {
        if isLiked {
            isLiked = false
            likeCount -= 1
        } else {
            isLiked = true
            likeCount += 1
            if isDisliked {
                isDisliked = false
                dislikeCount -= 1
            }
        }
    }

    private func toggleDislike() {
        if isDisliked {
            isDisliked = false
            dislikeCount -= 1
        } else {
            isDisliked = true
            dislikeCount += 1
            if isLiked {
                isLiked = false
                likeCount -= 1
            }
        }
    }

    private func formatCount(_ value: Int) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", Double(value) / 1000.0)
        }
        return "\(value)"
    }

    // Top row. The dismiss arrow is always visible; mute / menu only show
    // while the controls are visible.
    private var playerTopBar: some View {
        VStack {
            HStack(spacing: 4) {
                if showControls {
                    Button {
                        viewModel.toggleMute()
                        scheduleHide()
                    } label: {
                        Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .contentShape(Rectangle())
                    }
                }

                Spacer()

                if showControls {
                    Button {
                        showMenuSheet = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .contentShape(Rectangle())
                    }
                }

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 6)
            .padding(.top, topSafeAreaInset + 6)
            .padding(.bottom, 12)

            Spacer()
        }
    }

    private var playerPlaybackControls: some View {
        HStack(spacing: 32) {
            Button {
                viewModel.skip(by: -5)
                scheduleHide()
            } label: {
                Image(systemName: "gobackward.5")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Button {
                viewModel.togglePlayPause()
                scheduleHide()
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.black.opacity(0.50))
                    .clipShape(Circle())
            }

            Button {
                viewModel.skip(by: 5)
                scheduleHide()
            } label: {
                Image(systemName: "goforward.5")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var playerFullScreenButton: some View {
        VStack {
            Spacer()
            HStack(alignment: .center) {
                Text("\(viewModel.currentTimeText) / \(video.duration)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.leading, 12)

                Spacer()

                Button {
                    isFullScreen = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(12)
                }
            }
            // Sit above the persistent progress bar at the very bottom edge.
            .padding(.bottom, 22)
        }
    }

    /// Persistent playback indicator pinned to the player's bottom edge.
    private var playerProgressBar: some View {
        VStack {
            Spacer()
            PlaybackSeekBar(
                progress: viewModel.progress,
                isEnabled: showControls,
                onScrubStart: { viewModel.beginScrubbing() },
                onScrub: { fraction in viewModel.scrub(to: fraction) },
                onScrubEnd: { fraction in viewModel.endScrubbing(at: fraction) }
            )
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 4)
            .padding(.bottom, 2)
        }
    }

    /// A single YouTube-style suggested video card.
    private func suggestedCard(_ item: VideoModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ImageView(item.thumbnailURL)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    Text(item.duration)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .padding(8)
                }

            HStack(alignment: .top, spacing: 10) {
                ImageView(item.authorAvatarURL)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.videoInk)
                        .lineLimit(2)
                    Text("\(item.authorName) • \(item.views) • \(item.age)")
                        .font(.caption2)
                        .foregroundStyle(AppColor.videoInkMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "ellipsis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.videoInk)
                    .rotationEffect(.degrees(90))
            }
        }
    }

    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showControls.toggle()
        }
        if showControls {
            scheduleHide()
        } else {
            hideWorkItem?.cancel()
        }
    }

    /// Hides the controls after 2 seconds — but only while the video is
    /// playing. When paused, the controls stay visible.
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
}

private struct FullScreenVideoPlayer: View {
    let video: VideoModel
    @ObservedObject var viewModel: VideosViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLandscape: Bool = false
    @State private var showControls: Bool = true
    @State private var hideWorkItem: DispatchWorkItem?

    private var topSafeAreaInset: CGFloat {
        UIApplication.shared.keyWindowSafeAreaInsets.top
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                if let player = viewModel.player(for: video) {
                    // .resizeAspect keeps the original aspect ratio (no stretching)
                    VideoPlayerView(player: player, videoGravity: .resizeAspect)
                        .allowsHitTesting(false)
                }

                // Full-area tap layer to toggle the controls' visibility.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { toggleControls() }

                if showControls {
                    // Centered independently so it stays in the middle regardless
                    // of the top bar's height/padding.
                    playbackControls

                    topBar
                }
            }
            // Swap dimensions and rotate the whole player to emulate a
            // landscape layout while the app itself stays portrait-locked.
            .frame(
                width: isLandscape ? geo.size.height : geo.size.width,
                height: isLandscape ? geo.size.width : geo.size.height
            )
            .rotationEffect(.degrees(isLandscape ? 90 : 0))
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .ignoresSafeArea()
        .onAppear { scheduleHide() }
        .onDisappear { hideWorkItem?.cancel() }
    }

    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showControls.toggle()
        }
        if showControls {
            scheduleHide()
        } else {
            hideWorkItem?.cancel()
        }
    }

    /// Hides the controls after 2 seconds; call again to reset the timer
    /// whenever the user interacts with a control.
    private func scheduleHide() {
        hideWorkItem?.cancel()
        let work = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.25)) {
                showControls = false
            }
        }
        hideWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: work)
    }

    // Top row: close / rotate / mute. The top padding is small in landscape
    // (no notch along the rotated edge) and clears the safe area in portrait.
    private var topBar: some View {
        VStack {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLandscape.toggle()
                    }
                    scheduleHide()
                } label: {
                    Image(systemName: isLandscape ? "rectangle.portrait.rotate" : "rectangle.landscape.rotate")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }

                Button {
                    viewModel.toggleMute()
                    scheduleHide()
                } label: {
                    Image(systemName: viewModel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, isLandscape ? 40 : 16)
            .padding(.top, isLandscape ? 16 : topSafeAreaInset + 8)

            Spacer()
        }
    }

    private var playbackControls: some View {
        HStack(spacing: 40) {
            Button {
                viewModel.skip(by: -5)
                scheduleHide()
            } label: {
                Image(systemName: "gobackward.5")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Button {
                viewModel.togglePlayPause()
                scheduleHide()
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }

            Button {
                viewModel.skip(by: 5)
                scheduleHide()
            } label: {
                Image(systemName: "goforward.5")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }
}

extension UIApplication {
    /// Safe-area insets of the active key window. Useful for views that
    /// intentionally ignore the safe area but still need to pad their controls.
    var keyWindowSafeAreaInsets: UIEdgeInsets {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets ?? .zero
    }
}

#Preview {
    VideoDetailsView(
        video: VideoModel(
            id: "1",
            thumbnailURL: "https://picsum.photos/seed/binbon1/800/600",
            videoURL: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4"),
            duration: "1:40:39",
            title: "Lorem Ipsum is simply is lo @dummy text",
            hashtags: "#Lorem #Lorem #Lorem",
            views: "1k views",
            age: "1 hour ago",
            authorName: "MONA 🌹 FLOWR",
            authorAvatarURL: "https://picsum.photos/seed/avatar1/100"
        ),
        viewModel: VideosViewModel()
    )
}
