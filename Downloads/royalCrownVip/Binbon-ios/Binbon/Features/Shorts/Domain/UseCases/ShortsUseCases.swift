//
//  ShortsUseCases.swift
//  Binbon
//
//  Domain layer — shorts feed and per-short like operation.
//

import Foundation

struct FetchShortsUseCase {
    private let repository: ShortsRepositoryProtocol

    init(repository: ShortsRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ShortModel] {
        try await repository.fetchShorts()
    }
}

struct ToggleShortLikeUseCase {
    private let repository: ShortsRepositoryProtocol

    init(repository: ShortsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(shortID: ShortModel.ID, liked: Bool) async throws {
        try await repository.setShortLike(shortID: shortID, liked: liked)
    }
}
