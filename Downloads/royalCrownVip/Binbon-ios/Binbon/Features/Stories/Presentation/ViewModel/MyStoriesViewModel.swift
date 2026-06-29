//
//  MyStoriesViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 16/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class MyStoriesViewModel: ObservableObject {
    
    // MARK: - State
    @Published var profile: ProfileSummary?
    @Published var friends: [StoryFriend] = []
    @Published var stories: [Story] = []
    @Published var trending: [TrendingStory] = []
    @Published var savedGroups: [SavedStoryGroup] = []
    @Published var saveMyStoryDays: [SaveMyStoryDay] = []
    @Published var selectedSaveMyStoryDayID: String?
    @Published var deletedSaveMyStoryDayIDs: Set<String> = []
    @Published var selectedTab: StoryTab = .my
    @Published var isLoading: Bool = false
    @Published var error: APIError?
    
    // MARK: - Use cases
    private let fetchProfileSummaryUseCase: FetchStoryProfileSummaryUseCase
    private let fetchFriendsUseCase: FetchStoryFriendsUseCase
    private let fetchStoriesUseCase: FetchStoriesUseCase
    private let fetchTrendingUseCase: FetchTrendingStoriesUseCase
    private let fetchSavedUseCase: FetchSavedStoriesUseCase
    private let fetchSaveMyStoryDaysUseCase: FetchSaveMyStoryDaysUseCase

    init(
        fetchProfileSummaryUseCase: FetchStoryProfileSummaryUseCase,
        fetchFriendsUseCase: FetchStoryFriendsUseCase,
        fetchStoriesUseCase: FetchStoriesUseCase,
        fetchTrendingUseCase: FetchTrendingStoriesUseCase,
        fetchSavedUseCase: FetchSavedStoriesUseCase,
        fetchSaveMyStoryDaysUseCase: FetchSaveMyStoryDaysUseCase
    ) {
        self.fetchProfileSummaryUseCase = fetchProfileSummaryUseCase
        self.fetchFriendsUseCase = fetchFriendsUseCase
        self.fetchStoriesUseCase = fetchStoriesUseCase
        self.fetchTrendingUseCase = fetchTrendingUseCase
        self.fetchSavedUseCase = fetchSavedUseCase
        self.fetchSaveMyStoryDaysUseCase = fetchSaveMyStoryDaysUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        let repository = container.makeStoriesRepository()
        self.init(
            fetchProfileSummaryUseCase: FetchStoryProfileSummaryUseCase(repository: repository),
            fetchFriendsUseCase: FetchStoryFriendsUseCase(repository: repository),
            fetchStoriesUseCase: FetchStoriesUseCase(repository: repository),
            fetchTrendingUseCase: FetchTrendingStoriesUseCase(repository: repository),
            fetchSavedUseCase: FetchSavedStoriesUseCase(repository: repository),
            fetchSaveMyStoryDaysUseCase: FetchSaveMyStoryDaysUseCase(repository: repository)
        )
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
    
    // MARK: - Loading
    
    func loadInitial() {
        Task { await reloadAll() }
    }
    
    func select(tab: StoryTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        Task { await reloadStories() }
        if tab.usesGridLayout, trending.isEmpty {
            Task { await reloadTrending() }
        }
        if tab == .saved, savedGroups.isEmpty {
            Task { await reloadSaved() }
        }
    }
    
    // MARK: - Private
    
    private func reloadAll() async {
        isLoading = true
        error = nil
        async let profileResult = fetchProfileSummaryUseCase.execute()
        async let friendsResult = fetchFriendsUseCase.execute()
        async let storiesResult = fetchStoriesUseCase.execute(tab: selectedTab)

        do {
            let (profile, friends, stories) = try await (profileResult, friendsResult, storiesResult)
            self.profile = profile
            self.friends = friends
            self.stories = stories
        } catch {
            self.error = asAPIError(error)
        }

        isLoading = false
    }

    private func reloadStories() async {
        do {
            stories = try await fetchStoriesUseCase.execute(tab: selectedTab)
        } catch {
            self.error = asAPIError(error)
        }
    }

    private func reloadTrending() async {
        do {
            trending = try await fetchTrendingUseCase.execute()
        } catch {
            self.error = asAPIError(error)
        }
    }

    private func reloadSaved() async {
        do {
            savedGroups = try await fetchSavedUseCase.execute()
        } catch {
            self.error = asAPIError(error)
        }
    }

    // MARK: - Save my Story

    func loadSaveMyStoryDaysIfNeeded() {
        guard saveMyStoryDays.isEmpty else { return }
        Task { await reloadSaveMyStoryDays() }
    }

    func selectSaveMyStoryDay(id: String) {
        selectedSaveMyStoryDayID = id
    }

    var activeSaveMyStoryDay: SaveMyStoryDay? {
        guard let id = selectedSaveMyStoryDayID else { return saveMyStoryDays.first }
        return saveMyStoryDays.first { $0.id == id } ?? saveMyStoryDays.first
    }

    func deleteSaveMyStory(dayID: String) {
        deletedSaveMyStoryDayIDs.insert(dayID)
    }

    func isSaveMyStoryDeleted(dayID: String) -> Bool {
        deletedSaveMyStoryDayIDs.contains(dayID)
    }

    private func reloadSaveMyStoryDays() async {
        do {
            saveMyStoryDays = try await fetchSaveMyStoryDaysUseCase.execute()
            if selectedSaveMyStoryDayID == nil {
                selectedSaveMyStoryDayID = saveMyStoryDays.first?.id
            }
        } catch {
            self.error = asAPIError(error)
        }
    }
}
