//
//  PhotosViewModel.swift
//  Binbon
//

import Foundation
import Combine

@MainActor
final class PhotosViewModel: ObservableObject {

    enum ViewState {
        case idle
        case loading
        case loaded([PhotoPostModel])
        case failed(APIError)
    }

    @Published private(set) var state: ViewState = .idle
    @Published var isLoading = false
    @Published var error: APIError?

    private let fetchFeedUseCase: FetchPhotosFeedUseCase

    init(fetchFeedUseCase: FetchPhotosFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(fetchFeedUseCase: container.makeFetchPhotosFeedUseCase())
    }

    func load() {
        state = .loading
        isLoading = true
        Task {
            do {
                let posts = try await fetchFeedUseCase.execute()
                state = .loaded(posts)
            } catch {
                let apiError = (error as? APIError) ?? Network.shared.mapError(error)
                self.error = apiError
                state = .failed(apiError)
            }
            isLoading = false
        }
    }

    // MARK: - Engagement
    // Local-only toggles for now; persist through the repo once the API lands.

    func toggleLike(_ id: PhotoPostModel.ID) {
        update(id) { post in
            post.isLiked.toggle()
            post.likeCount += post.isLiked ? 1 : -1
        }
    }

    func toggleBookmark(_ id: PhotoPostModel.ID) {
        update(id) { $0.isBookmarked.toggle() }
    }

    private func update(_ id: PhotoPostModel.ID, _ transform: (inout PhotoPostModel) -> Void) {
        guard case .loaded(var posts) = state,
              let index = posts.firstIndex(where: { $0.id == id }) else { return }
        transform(&posts[index])
        state = .loaded(posts)
    }
}
