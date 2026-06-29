//
//  StoriesRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — stories boundary the use cases depend on. Returns entities and
//  throws `APIError`; the transport envelope never leaks past here.
//

import Foundation

protocol StoriesRepositoryProtocol {
    func fetchProfileSummary() async throws -> ProfileSummary
    func fetchFriendsWithStories() async throws -> [StoryFriend]
    func fetchStories(for tab: StoryTab) async throws -> [Story]
    func fetchTrendingStories() async throws -> [TrendingStory]
    func fetchSavedStories() async throws -> [SavedStoryGroup]
    func fetchSaveMyStoryDays() async throws -> [SaveMyStoryDay]
}
