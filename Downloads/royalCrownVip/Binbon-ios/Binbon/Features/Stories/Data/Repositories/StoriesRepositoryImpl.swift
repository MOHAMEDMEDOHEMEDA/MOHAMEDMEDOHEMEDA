//
//  StoriesRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `StoriesRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class StoriesRepositoryImpl: StoriesRepositoryProtocol {

    private let remote: StoriesRemoteDataSource

    init(remote: StoriesRemoteDataSource) {
        self.remote = remote
    }

    func fetchProfileSummary() async throws -> ProfileSummary {
        try await remote.fetchProfileSummary()
    }

    func fetchFriendsWithStories() async throws -> [StoryFriend] {
        try await remote.fetchFriendsWithStories()
    }

    func fetchStories(for tab: StoryTab) async throws -> [Story] {
        try await remote.fetchStories(for: tab)
    }

    func fetchTrendingStories() async throws -> [TrendingStory] {
        try await remote.fetchTrendingStories()
    }

    func fetchSavedStories() async throws -> [SavedStoryGroup] {
        try await remote.fetchSavedStories()
    }

    func fetchSaveMyStoryDays() async throws -> [SaveMyStoryDay] {
        try await remote.fetchSaveMyStoryDays()
    }
}
