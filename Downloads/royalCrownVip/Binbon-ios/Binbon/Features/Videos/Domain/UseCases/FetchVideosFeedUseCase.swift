//
//  FetchVideosFeedUseCase.swift
//  Binbon
//
//  Domain layer — loads the videos feed.
//

import Foundation

struct FetchVideosFeedUseCase {
    private let repository: VideosRepositoryProtocol

    init(repository: VideosRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [VideoModel] {
        try await repository.fetchVideosFeed()
    }
}
