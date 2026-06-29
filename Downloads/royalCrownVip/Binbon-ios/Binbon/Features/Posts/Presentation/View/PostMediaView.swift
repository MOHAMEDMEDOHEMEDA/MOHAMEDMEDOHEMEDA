//
//  PostMediaView.swift
//  Binbon
//
//  Renders a post's attached media: an image collage (1–4 tiles with a +N
//  overlay for extras) or a video thumbnail with a play button. Tapping an
//  image opens a paged full-screen viewer; tapping the video plays it full
//  screen.
//

import SwiftUI
import AVKit

// MARK: - PostImageSource rendering

extension PostImageSource {
    /// A resizable Image for this source (asset or picked data).
    @ViewBuilder
    func resizableImage() -> some View {
        switch self {
        case .asset(let name):
            Image(name).resizable()
        case .data(let data):
            if let ui = UIImage(data: data) {
                Image(uiImage: ui).resizable()
            } else {
                Color.gray
            }
        }
    }
}

// MARK: - Media

struct PostMediaView: View {
    let media: PostMedia

    private let height: CGFloat = 320
    private let gap: CGFloat = 3
    private let radius: CGFloat = 14

    /// Item index to open in the full-screen pager (pages through all media).
    @State private var viewerStart: ImageViewerStart?

    private var items: [PostMediaItem] {
        if case .items(let list) = media { return list }
        return []
    }

    var body: some View {
        Group {
            if items.isEmpty {
                EmptyView()
            } else {
                collage(items)
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            }
        }
        .fullScreenCover(item: $viewerStart) { start in
            PostMediaViewerView(items: items, startIndex: start.index)
        }
    }

    /// Opens the full-screen pager at the tapped item — images and videos alike.
    private func openItem(at index: Int) {
        viewerStart = ImageViewerStart(index: index)
    }

    // MARK: - Collage

    @ViewBuilder
    private func collage(_ items: [PostMediaItem]) -> some View {
        switch items.count {
        case 0:
            EmptyView()
        case 1:
            tappableTile(items, 0)
        case 2:
            HStack(spacing: gap) {
                tappableTile(items, 0)
                tappableTile(items, 1)
            }
        case 3:
            HStack(spacing: gap) {
                tappableTile(items, 0)
                VStack(spacing: gap) {
                    tappableTile(items, 1)
                    tappableTile(items, 2)
                }
            }
        default:
            // 2×2 grid; the 4th tile shows "+N" when there are more items.
            VStack(spacing: gap) {
                HStack(spacing: gap) {
                    tappableTile(items, 0)
                    tappableTile(items, 1)
                }
                HStack(spacing: gap) {
                    tappableTile(items, 2)
                    tappableTile(items, 3)
                        .overlay { overflowOverlay(extra: items.count - 4) }
                }
            }
        }
    }

    private func tappableTile(_ items: [PostMediaItem], _ index: Int) -> some View {
        Button { openItem(at: index) } label: {
            tile(items[index])
        }
        .buttonStyle(.plain)
    }

    /// A single tile that fills and crops its slot, with a play badge for videos.
    private func tile(_ item: PostMediaItem) -> some View {
        Color.clear
            .overlay {
                item.thumbnail.resizableImage()
                    .scaledToFill()
            }
            .overlay {
                if item.isVideo {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.black.opacity(0.35)))
                }
            }
            .clipped()
            .contentShape(Rectangle())
    }

    @ViewBuilder
    private func overflowOverlay(extra: Int) -> some View {
        if extra > 0 {
            ZStack {
                Color.black.opacity(0.5)
                Text("+\(extra)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }
            .allowsHitTesting(false)
        }
    }
}

private struct ImageViewerStart: Identifiable {
    let index: Int
    var id: Int { index }
}

// MARK: - Full-screen paged media viewer (images + videos)

private struct PostMediaViewerView: View {
    let items: [PostMediaItem]
    @State var index: Int
    @Environment(\.dismiss) private var dismiss

    init(items: [PostMediaItem], startIndex: Int) {
        self.items = items
        _index = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $index) {
                ForEach(Array(items.enumerated()), id: \.offset) { offset, item in
                    Group {
                        switch item {
                        case .image(let source):
                            ZoomableImage(source: source)
                        case .video(_, let url):
                            PagerVideoView(url: url, isActive: index == offset)
                        }
                    }
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: items.count > 1 ? .automatic : .never))
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))

            closeButton
        }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.black.opacity(0.4)))
        }
        .buttonStyle(.plain)
        .padding(16)
    }
}

/// A video page in the pager: plays while it's the visible page, pauses otherwise.
private struct PagerVideoView: View {
    let url: URL
    let isActive: Bool
    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if player == nil { player = AVPlayer(url: url) }
                if isActive { player?.play() }
            }
            .onChange(of: isActive) { _, active in
                if active { player?.play() } else { player?.pause() }
            }
            .onDisappear { player?.pause() }
    }
}

/// A single full-screen image with double-tap to zoom and pinch-to-zoom.
private struct ZoomableImage: View {
    let source: PostImageSource
    @State private var scale: CGFloat = 1

    var body: some View {
        source.resizableImage()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(scale)
            .clipped()
            .ignoresSafeArea()
            .gesture(
                MagnificationGesture()
                    .onChanged { scale = max(1, min($0, 4)) }
                    .onEnded { _ in if scale < 1.05 { withAnimation { scale = 1 } } }
            )
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    scale = scale > 1 ? 1 : 2.5
                }
            }
    }
}

