//
//  CommentsViewModel.swift
//  Binbon
//

import Foundation
import Combine

@MainActor
final class CommentsViewModel: ObservableObject {

    enum ViewState {
        case idle
        case loading
        case loaded([CommentModel])
        case failed(APIError)
    }

    @Published private(set) var state: ViewState = .idle
    @Published var isLoading = false
    @Published var error: APIError?

    /// Total comment count shown in the header — seeded from the host item so it
    /// reads correctly before the thread finishes loading.
    let commentCount: Int

    private let targetID: String
    private let fetchCommentsUseCase: FetchCommentsUseCase

    init(
        targetID: String,
        initialCount: Int = 0,
        fetchCommentsUseCase: FetchCommentsUseCase
    ) {
        self.targetID = targetID
        self.commentCount = initialCount
        self.fetchCommentsUseCase = fetchCommentsUseCase
    }

    convenience init(targetID: String, initialCount: Int = 0, container: AppDIContainer = .shared) {
        self.init(
            targetID: targetID,
            initialCount: initialCount,
            fetchCommentsUseCase: container.makeFetchCommentsUseCase()
        )
    }

    func load() {
        state = .loading
        isLoading = true
        Task {
            do {
                let comments = try await fetchCommentsUseCase.execute(targetID: targetID)
                state = .loaded(comments)
            } catch {
                let apiError = (error as? APIError) ?? Network.shared.mapError(error)
                self.error = apiError
                state = .failed(apiError)
            }
            isLoading = false
        }
    }

    // MARK: - Engagement
    // Local-only toggle for now; persist through the repo once the API lands.

    func toggleLike(_ id: CommentModel.ID) {
        guard case .loaded(var comments) = state,
              let index = comments.firstIndex(where: { $0.id == id }) else { return }
        comments[index].isLiked.toggle()
        comments[index].likeCount += comments[index].isLiked ? 1 : -1
        state = .loaded(comments)
    }
}
