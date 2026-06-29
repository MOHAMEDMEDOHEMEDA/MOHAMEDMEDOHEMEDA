//
//  PostsView.swift
//  Binbon
//
//  The "Posts" home tab: a composer row plus a vertical feed of posts.
//

import SwiftUI

struct PostsView: View {

    @StateObject private var viewModel = PostsViewModel()
    @ObservedObject private var theme = ThemeManager.shared
    @State private var showNewPost = false
    @State private var optionsPostID: String?
    @State private var pendingDeletePost: PostModel?

    /// Avatar used for the composer row / current user (mock).
    private let myAvatar = "media-reel-1"

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                composerRow
                rowDivider

                ForEach(viewModel.posts) { post in
                    PostCardView(
                        post: post,
                        onLike: { viewModel.toggleLike(post.id) },
                        onBookmark: { viewModel.toggleBookmark(post.id) },
                        onOptions: { optionsPostID = post.id }
                    )
                    rowDivider
                }
            }
            // Clear the home search header + tab pills at the top and the tab bar
            // at the bottom.
            .padding(.top, 118)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        .overlay { optionsScrim }
        .overlayPreferenceValue(PostEllipsisAnchorKey.self) { anchors in
            optionsMenu(anchors: anchors)
        }
        .overlay { deleteDialog }
        .animation(.easeInOut(duration: 0.18), value: optionsPostID)
        .animation(.easeInOut(duration: 0.2), value: pendingDeletePost)
        .onAppear { viewModel.load() }
        .fullScreenCover(isPresented: $showNewPost) {
            NewPostView(myAvatar: myAvatar) { caption, media in
                viewModel.addPost(caption: caption, media: media, avatar: myAvatar)
                Toaster.shared.show(.success("checkmark.circle.fill"), "new_post".localized)
            }
        }
    }

    // MARK: - Post options menu

    @ViewBuilder
    private var optionsScrim: some View {
        if optionsPostID != nil {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { optionsPostID = nil }
        }
    }

    @ViewBuilder
    private func optionsMenu(anchors: [String: Anchor<CGPoint>]) -> some View {
        GeometryReader { proxy in
            if let id = optionsPostID, let anchor = anchors[id] {
                let point = proxy[anchor]
                PostOptionsMenu(
                    onReport: { optionsPostID = nil },
                    onBlock: { optionsPostID = nil },
                    onDelete: {
                        let post = viewModel.posts.first { $0.id == id }
                        optionsPostID = nil
                        pendingDeletePost = post
                    }
                )
                .offset(x: point.x - 230, y: point.y + 6)
                .transition(.scale(scale: 0.9, anchor: .topTrailing).combined(with: .opacity))
            }
        }
    }

    // MARK: - Delete confirmation

    @ViewBuilder
    private var deleteDialog: some View {
        if let post = pendingDeletePost {
            ZStack {
                AppColor.confirmPopupScrim
                    .ignoresSafeArea()
                    .onTapGesture { pendingDeletePost = nil }

                DeletePostDialog(
                    onCancel: { pendingDeletePost = nil },
                    onDelete: {
                        pendingDeletePost = nil
                        viewModel.delete(post.id)
                        Toaster.shared.show(.success("checkmark.circle.fill"), "post_deleted".localized)
                    }
                )
                .transition(.scale(scale: 0.92).combined(with: .opacity))
            }
            .zIndex(2)
        }
    }

    private var rowDivider: some View {
        Divider().overlay(Color.appText.opacity(0.12))
    }

    // MARK: - Composer row
    private var composerRow: some View {
        Button { showNewPost = true } label: {
            HStack(spacing: 12) {
                Image(myAvatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())

                Text("whats_on_your_mind".localized)
                    .font(.system(size: 15))
                    .foregroundStyle(.appText.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .frame(height: 46)
                    .background(Capsule().fill(Color.appText.opacity(0.12)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PostsView()
}
