//
//  PostsViewModel.swift
//  Binbon
//
//  Drives the Posts feed: loads mock posts and toggles like/bookmark state.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class PostsViewModel: ObservableObject {

    @Published private(set) var posts: [PostModel] = []

    private let loadFeedUseCase: LoadPostsFeedUseCase

    init(loadFeedUseCase: LoadPostsFeedUseCase) {
        self.loadFeedUseCase = loadFeedUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(loadFeedUseCase: container.makeLoadPostsFeedUseCase())
    }

    func load() {
        Task {
            do {
                posts = try await loadFeedUseCase.execute()
            } catch {
                posts = []
            }
        }
    }

    func toggleLike(_ id: PostModel.ID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likes += posts[index].isLiked ? 1 : -1
    }

    func toggleBookmark(_ id: PostModel.ID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].isBookmarked.toggle()
    }

    func delete(_ id: PostModel.ID) {
        withAnimation(.easeInOut(duration: 0.25)) {
            posts.removeAll { $0.id == id }
        }
    }

    /// Prepends a freshly composed post (from NewPostView) to the top of the feed.
    func addPost(caption: String, media picked: [PickedMedia], avatar: String) {
        let media = Self.buildMedia(from: picked)

        let post = PostModel(
            id: UUID().uuidString,
            authorName: "you".localized,
            username: "@maya.carter",
            avatar: avatar,
            timeAgo: "now",
            caption: caption,
            media: media,
            likes: 0,
            comments: 0,
            reposts: 0,
            isLiked: false,
            isBookmarked: false
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            posts.insert(post, at: 0)
        }
    }

    /// Maps the picked media (images and videos, in order) to the post's media.
    private static func buildMedia(from picked: [PickedMedia]) -> PostMedia {
        let items = picked.map { item -> PostMediaItem in
            switch item.kind {
            case .image(let data):
                return .image(.data(data))
            case .video(let url, let thumbnail):
                return .video(thumbnail: .data(thumbnail), url: url)
            }
        }
        return items.isEmpty ? .none : .items(items)
    }
}
