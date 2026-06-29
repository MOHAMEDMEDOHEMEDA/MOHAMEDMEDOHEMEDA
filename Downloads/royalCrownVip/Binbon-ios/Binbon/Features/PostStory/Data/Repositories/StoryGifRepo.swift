//
//  StoryGifRepo.swift
//  Binbon
//

import Foundation

final class StoryGifRepo: Repo, StoryGifRepoProtocol {

    private static let samples: [StoryGifItem] = [
        .init(
            id: "1",
            title: "Wave",
            previewURL: StoryGifURLResolver.bundleReference(name: "sample-gif-wave"),
            fullURL: StoryGifURLResolver.bundleReference(name: "sample-gif-wave")
        ),
        .init(
            id: "2",
            title: "Thumbs up",
            previewURL: StoryGifURLResolver.bundleReference(name: "sample-gif-thumbsup"),
            fullURL: StoryGifURLResolver.bundleReference(name: "sample-gif-thumbsup")
        ),
        .init(
            id: "3",
            title: "Celebrate",
            previewURL: StoryGifURLResolver.bundleReference(name: "sample-gif-celebrate"),
            fullURL: StoryGifURLResolver.bundleReference(name: "sample-gif-celebrate")
        ),
    ]

    func trending() async -> Result<[StoryGifItem], APIError> {
        .success(Self.samples)
    }

    func search(query: String) async -> Result<[StoryGifItem], APIError> {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return await trending() }
        let filtered = Self.samples.filter { $0.title.lowercased().contains(q) }
        return .success(filtered)
    }
}
