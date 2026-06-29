//
//  FetchPhotosFeedUseCase.swift
//  Binbon
//
//  Domain layer — loads the photos feed.
//

import Foundation

struct FetchPhotosFeedUseCase {
    private let repository: PhotosRepositoryProtocol

    init(repository: PhotosRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [PhotoPostModel] {
        try await repository.fetchFeed()
    }
}
