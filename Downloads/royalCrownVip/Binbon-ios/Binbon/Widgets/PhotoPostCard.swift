//
//  PhotoPostCard.swift
//  Binbon
//

import SwiftUI

struct PhotoPostCard: View {
    let post: PhotoPostModel
    var onLike: () -> Void = {}
    var onBookmark: () -> Void = {}
    var onComment: () -> Void = {}
    var onTapHeader: () -> Void = {}

    @State private var currentPhoto: Int? = 0
    @State private var poppingHearts: [PoppingHeart] = []

    @State private var showFullScreen = false
    @State private var fullScreenStart = 0
    @State private var showShareSheet = false

    @State private var isReposted = false
    @State private var repostSpin = 0.0
    @State private var repostAvatars: [String] = []
    @State private var seededReposts = false

    @Namespace private var photoZoom
    private let carouselSpace = "photoCarousel"

    /// Current user's avatar — appended to the reposters arc when reposting.
    private let myAvatarURL = "https://i.pravatar.cc/150?img=68"

    @State private var showSaveSheet = false
    @State private var showOptions = false

    private var shareURL: URL {
        URL(string: "https://binbon.app/p/\(post.id)") ?? URL(string: "https://binbon.app")!
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header.padding(.horizontal, 16)
            photoCarousel.padding(.horizontal, 1)
            if post.photoURLs.count > 1 {
                pageDots.padding(.horizontal, 16)
            }
            engagementRow.padding(.horizontal, 16)
            ExpandableCaption(author: post.author, caption: post.caption)
                .padding(.horizontal, 16)
        }
        .shareSheet(isPresented: $showShareSheet, shareURL: shareURL)
        .sheet(isPresented: $showSaveSheet) {
            SaveToCollectionSheet()
                .presentationDetents([.fraction(0.45), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationBackground(AppColor.cardBackground)
        }
        .onAppear {
            if !seededReposts {
                repostAvatars = post.repostAvatars
                seededReposts = true
            }
        }
    }

    // MARK: Header
    private var header: some View {
        HStack(spacing: 9) {
            Button(action: onTapHeader) {
                HStack(spacing: 9) {
                    ImageView(post.avatarURL)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    Text(post.author)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

         
        }
    }

    // MARK: Photo carousel
    private var photoCarousel: some View {
        GeometryReader { geo in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(post.photoURLs.enumerated()), id: \.offset) { index, url in
                        ImageView(url)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .contentShape(Rectangle())
                            .onTapGesture(count: 2, coordinateSpace: .named(carouselSpace)) { location in
                                handleDoubleTap(at: location)
                            }
                            .onTapGesture { openFullScreen(at: index) }
                            .id(index)
                    }
                }
                .scrollTargetLayout()
                .background(ScrollBounceDisabler())
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentPhoto)
            .scrollIndicators(.hidden)
        }
        .frame(height: 346)
        .overlay(alignment: .bottomTrailing) {
            repostBadges
                .padding(12)
                .offset(x:-20,y: 20)
        }
        .overlay { heartsLayer }
        .clipShape(Rectangle())
        .coordinateSpace(name: carouselSpace)
        .zoomSource(id: post.id, in: photoZoom)
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenPhotoView(photoURLs: post.photoURLs,
                                startIndex: fullScreenStart,
                                zoomID: post.id,
                                namespace: photoZoom,
                                isPresented: $showFullScreen,
                                cardIndex: $currentPhoto)
        }
    }

    private func openFullScreen(at index: Int) {
        fullScreenStart = index
        if #available(iOS 18.0, *) {
            showFullScreen = true
        } else {
            var transaction = SwiftUI.Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { showFullScreen = true }
        }
    }

    private var heartsLayer: some View {
        ZStack {
            ForEach(poppingHearts) { heart in
                PoppingHeartView(at: heart.position)
            }
        }
        .allowsHitTesting(false)
    }

    private func handleDoubleTap(at location: CGPoint) {
        if !post.isLiked {
            let heart = PoppingHeart(position: location)
            poppingHearts.append(heart)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                poppingHearts.removeAll { $0.id == heart.id }
            }
        }
        onLike()
    }

    private var repostBadges: some View {
        let avatars = repostAvatars
        return ZStack {
            ForEach(Array(avatars.enumerated()), id: \.offset) { index, avatar in
                ImageView(avatar)
                    .frame(width: 41, height: 41)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColor.textPrimary, lineWidth: 1))
                    .overlay(alignment: .bottomTrailing) {
                        Image("Reposted")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                    .offset(arcOffset(index: index, count: avatars.count))
                    .zIndex(Double(index))
            }
        }
    }

    private func arcOffset(index: Int, count: Int) -> CGSize {
        guard count > 1 else { return .zero }
        let radius: CGFloat = 60
        let startAngle: CGFloat = 80   // lower-left
        let endAngle: CGFloat = 150      // top
        let t = CGFloat(index) / CGFloat(count - 1)
        let angle = (startAngle + (endAngle - startAngle) * t) * .pi / 180
        return CGSize(width: radius * cos(angle), height: -radius * sin(angle))
    }

    // MARK: Page dots
    private var pageDots: some View {
        PageDots(count: post.photoURLs.count, current: currentPhoto ?? 0)
            .frame(maxWidth: .infinity)
    }

    // MARK: Engagement
    private var engagementRow: some View {
        HStack(spacing: 15) {
            PhotoLikeButton(isLiked: post.isLiked,
                            count: post.likeCount.feedFormatted,
                            action: onLike)

            Button(action: onComment) {
                HStack(spacing: 6) {
                    assetIcon("Comment", size: 19)
                    Text("\(post.commentCount)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.textPrimary)
                }
                .contentShape(Rectangle())
            }

            Button { toggleRepost() } label: {
                Image("Repost")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(isReposted ? Color.appGold : AppColor.textPrimary)
                    .rotationEffect(.degrees(repostSpin))
                    .contentShape(Rectangle())
            }

            Button { showShareSheet = true } label: {
                assetIcon("Share")
            }

            Spacer()

            PhotoBookmarkButton(isBookmarked: post.isBookmarked) {
                onBookmark()
                showSaveSheet = true
            }
        }
        .buttonStyle(.plain)
    }

    /// Spin the arrows, tint gold, and append the current user to the reposters
    /// arc over the photo. A second tap undoes it.
    private func toggleRepost() {
        isReposted.toggle()
        withAnimation(.easeInOut(duration: 0.6)) { repostSpin += 360 }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
            if isReposted {
                if !repostAvatars.contains(myAvatarURL) { repostAvatars.append(myAvatarURL) }
            } else {
                repostAvatars.removeAll { $0 == myAvatarURL }
            }
        }
    }

    private func assetIcon(_ name: String, size: CGFloat = 22) -> some View {
        Image(name)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(AppColor.textPrimary)
    }
}

private extension Int {
    var feedFormatted: String {
        guard self >= 1000 else { return "\(self)" }
        let thousands = self / 1000
        let remainder = self % 1000
        return "\(thousands)'\(String(format: "%03d", remainder))"
    }
}

#Preview {
    PhotoPostCard(post: PhotoPostModel.mockFeed[0])
        .background(AppColor.backgroundGradient)
}
