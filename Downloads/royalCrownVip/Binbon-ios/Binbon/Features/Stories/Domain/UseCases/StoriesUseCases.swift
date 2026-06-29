//
//  StoriesUseCases.swift
//  Binbon
//
//  Domain layer — one use case per stories read operation. Grouped in a single
//  file since each is a thin pass-through over `StoriesRepositoryProtocol`.
//

import Foundation

struct FetchStoryProfileSummaryUseCase {
    private let repository: StoriesRepositoryProtocol
    init(repository: StoriesRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> ProfileSummary {
        try await repository.fetchProfileSummary()
    }
}

struct FetchStoryFriendsUseCase {
    private let repository: StoriesRepositoryProtocol
    init(repository: StoriesRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [StoryFriend] {
        try await repository.fetchFriendsWithStories()
    }
}

struct FetchStoriesUseCase {
    private let repository: StoriesRepositoryProtocol
    init(repository: StoriesRepositoryProtocol) { self.repository = repository }
    func execute(tab: StoryTab) async throws -> [Story] {
        try await repository.fetchStories(for: tab)
    }
}

struct FetchTrendingStoriesUseCase {
    private let repository: StoriesRepositoryProtocol
    init(repository: StoriesRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [TrendingStory] {
        try await repository.fetchTrendingStories()
    }
}

struct FetchSavedStoriesUseCase {
    private let repository: StoriesRepositoryProtocol
    init(repository: StoriesRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [SavedStoryGroup] {
        try await repository.fetchSavedStories()
    }
}

struct FetchSaveMyStoryDaysUseCase {
    private let repository: StoriesRepositoryProtocol
    init(repository: StoriesRepositoryProtocol) { self.repository = repository }
    func execute() async throws -> [SaveMyStoryDay] {
        try await repository.fetchSaveMyStoryDays()
    }
}
