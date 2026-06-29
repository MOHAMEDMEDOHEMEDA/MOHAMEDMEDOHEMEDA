//
//  PostCardView.swift
//  Binbon
//
//  A single post in the Posts feed: header, caption, optional media collage /
//  video, and the like / comment / repost / share / bookmark action bar.
//

import SwiftUI

struct PostCardView: View {
    let post: PostModel
    var onLike: () -> Void = {}
    var onBookmark: () -> Void = {}
    var onOptions: () -> Void = {}

    @State private var showComments = false
    @State private var showLikeHeart = false
    @State private var showShareSheet = false
    @State private var showSendSheet = false

    @State private var isReposted = false
    @State private var repostSpin = 0.0
    @State private var repostCount = 0

    private var shareURL: URL {
        URL(string: "https://binbon.app/post/\(post.id)") ?? URL(string: "https://binbon.app")!
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.system(size: 16))
                    .foregroundStyle(.appText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if post.media != .none {
                PostMediaView(media: post.media)
            }

            actionBar
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        // Double-tap anywhere on the post to love it; single taps still reach the
        // media tiles and action buttons.
        .highPriorityGesture(TapGesture(count: 2).onEnded { doubleTapLike() })
        .overlay {
            if showLikeHeart {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(.red)
                    .shadow(color: .black.opacity(0.35), radius: 10)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showComments) {
            RichCommentsView()
                .presentationDetents([.fraction(0.85), .large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(20)
        }
        .systemShareSheet(isPresented: $showShareSheet, items: [shareURL])
        .sheet(isPresented: $showSendSheet) {
            ReelSendToSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(28)
        }
        .onAppear { if repostCount == 0 { repostCount = post.reposts } }
    }

    private func doubleTapLike() {
        if !post.isLiked { onLike() }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
            showLikeHeart = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.35)) { showLikeHeart = false }
        }
    }

    // MARK: Header
    private var header: some View {
        HStack(spacing: 10) {
            Image(post.avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(post.authorName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.appText)

                Text("\(post.username) · \(post.timeAgo)")
                    .font(.system(size: 13))
                    .foregroundStyle(.appText.opacity(0.7))
            }

            Spacer()

            Button {
                onOptions()
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.appText.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
                    .anchorPreference(key: PostEllipsisAnchorKey.self, value: .bottom) {
                        [post.id: $0]
                    }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Action bar
    private var actionBar: some View {
        HStack(spacing: 16) {
            PhotoLikeButton(
                isLiked: post.isLiked,
                count: post.likes.postCountFormatted,
                action: onLike
            )

            Button {
                showComments = true
            } label: {
                actionLabel(asset: "Comment", text: post.comments.postCountFormatted, size: 19)
            }

            repostButton

            Button {
                showShareSheet = true
            } label: {
                assetIcon("reels-share", size: 24)
            }

            Button {
                showSendSheet = true
            } label: {
                Image(systemName: "paperplane")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.appText)
            }

            Spacer()

            PhotoBookmarkButton(isBookmarked: post.isBookmarked, action: onBookmark)
        }
        .buttonStyle(.plain)
    }

    private var repostButton: some View {
        Button {
            repost()
        } label: {
            HStack(spacing: 6) {
                Image("Repost")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(isReposted ? Color.appGold : .appText)
                    .rotationEffect(.degrees(repostSpin))

                Text(repostCount.postCountFormatted)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isReposted ? Color.appGold : .appText)
            }
            .contentShape(Rectangle())
        }
    }

    /// Spin the arrows and bump the count. Toggles so a second tap undoes it.
    private func repost() {
        isReposted.toggle()
        withAnimation(.easeInOut(duration: 0.6)) { repostSpin += 360 }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            repostCount += isReposted ? 1 : -1
        }
    }

    private func actionLabel(asset: String, text: String, size: CGFloat) -> some View {
        HStack(spacing: 6) {
            assetIcon(asset, size: size)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.appText)
        }
        .contentShape(Rectangle())
    }

    private func assetIcon(_ name: String, size: CGFloat = 22) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(.appText)
    }
}
