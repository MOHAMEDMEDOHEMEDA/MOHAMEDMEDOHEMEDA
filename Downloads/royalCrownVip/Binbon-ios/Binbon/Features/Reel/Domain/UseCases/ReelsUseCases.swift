//
//  ReelsUseCases.swift
//  Binbon
//
//  Domain layer — reels feed and per-reel like/bookmark operations.
//

import Foundation

struct FetchReelsUseCase {
    private let repository: ReelsRepositoryProtocol

    init(repository: ReelsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ReelModel] {
        try await repository.fetchReels()
    }
}

struct ToggleReelLikeUseCase {
    private let repository: ReelsRepositoryProtocol

    init(repository: ReelsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reelID: ReelModel.ID, liked: Bool) async throws {
        try await repository.setReelLike(reelID: reelID, liked: liked)
    }
}

struct ToggleReelBookmarkUseCase {
    private let repository: ReelsRepositoryProtocol

    init(repository: ReelsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reelID: ReelModel.ID, bookmarked: Bool) async throws {
        try await repository.setReelBookmark(reelID: reelID, bookmarked: bookmarked)
    }
}
