//
//  StoriesRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for stories. Mock-backed during the current
//  pre-integration phase; returns domain entities (no transport envelope).
//

import Foundation

protocol StoriesRemoteDataSource {
    func fetchProfileSummary() async throws -> ProfileSummary
    func fetchFriendsWithStories() async throws -> [StoryFriend]
    func fetchStories(for tab: StoryTab) async throws -> [Story]
    func fetchTrendingStories() async throws -> [TrendingStory]
    func fetchSavedStories() async throws -> [SavedStoryGroup]
    func fetchSaveMyStoryDays() async throws -> [SaveMyStoryDay]
}

// MARK: - Mock

struct MockStoriesRemoteDataSource: StoriesRemoteDataSource {

    func fetchProfileSummary() async throws -> ProfileSummary {
        ProfileSummary(
            displayName: "أحمد جاد",
            binbonId: "140578996",
            zodiacLabel: AppStrings.storyZodiacLibra.localized,
            avatarAssetName: nil,
            coverAssetName: nil,
            coverCaption: AppStrings.storyCoverOfficial.localized,
            likesText: "265 M",
            followersText: "505 K",
            followingText: "123 K",
            isVerified: true
        )
    }

    func fetchFriendsWithStories() async throws -> [StoryFriend] {
        [
            .init(id: "f1", displayName: "Ahmed", avatarAssetName: "artist_3"),
            .init(id: "f2", displayName: "Sameh", avatarAssetName: "artist_4"),
            .init(id: "f3", displayName: "Nada",  avatarAssetName: "artist_3"),
            .init(id: "f4", displayName: "Moaz",  avatarAssetName: "artist_5"),
            .init(id: "f5", displayName: "Hala",  avatarAssetName: "artist_4"),
            .init(id: "f1", displayName: "Ahmed", avatarAssetName: "artist_3"),
            .init(id: "f2", displayName: "Sameh", avatarAssetName: "artist_3"),
            .init(id: "f3", displayName: "Nada",  avatarAssetName: "artist_3"),
            .init(id: "f4", displayName: "Moaz",  avatarAssetName: "artist_4"),
            .init(id: "f5", displayName: "Hala",  avatarAssetName: "artist_5"),
        ]
    }

    func fetchStories(for tab: StoryTab) async throws -> [Story] {
        []
    }

    func fetchSaveMyStoryDays() async throws -> [SaveMyStoryDay] {
        [
            .init(id: "today", titleKey: AppStrings.saveMyStoryDayToday, dateText: nil,
                  captionKey: AppStrings.saveMyStoryCaptionToday, bodyDateText: "23/11/2025"),
            .init(id: "yesterday", titleKey: AppStrings.saveMyStoryDayYesterday, dateText: "22/11/2025",
                  captionKey: AppStrings.saveMyStoryCaptionYesterday, bodyDateText: "22/11/2025"),
            .init(id: "before-1", titleKey: AppStrings.saveMyStoryDayBefore, dateText: "3/11/2025",
                  captionKey: AppStrings.saveMyStoryCaptionBefore, bodyDateText: "3/11/2025"),
            .init(id: "before-2", titleKey: AppStrings.saveMyStoryDayBefore, dateText: "6/11/2025",
                  captionKey: AppStrings.saveMyStoryCaptionBefore, bodyDateText: "6/11/2025"),
            .init(id: "before-3", titleKey: AppStrings.saveMyStoryDayBefore, dateText: "24/10/2025",
                  captionKey: AppStrings.saveMyStoryCaptionBefore, bodyDateText: "24/10/2025"),
            .init(id: "before-4", titleKey: AppStrings.saveMyStoryDayBefore, dateText: "13/10/2025",
                  captionKey: AppStrings.saveMyStoryCaptionBefore, bodyDateText: "13/10/2025"),
        ]
    }

    func fetchSavedStories() async throws -> [SavedStoryGroup] {
        let tuesday = SavedStoryGroup(
            id: "g1", dateText: "20/11/2025", weekdayText: "الثلاثاء",
            stories: (0..<5).map { i in
                SavedStory(id: "s1-\(i)", savedDateText: "20/11/2025",
                           avatarAssetName: ["artist_3", "artist_4", "artist_5"][i % 3])
            }
        )
        let wednesday = SavedStoryGroup(
            id: "g2", dateText: "19/11/2025", weekdayText: "الأربعاء",
            stories: (0..<5).map { i in
                SavedStory(id: "s2-\(i)", savedDateText: "19/11/2025",
                           avatarAssetName: ["artist_4", "artist_3", "artist_5"][i % 3])
            }
        )
        let thursday = SavedStoryGroup(
            id: "g3", dateText: "18/11/2025", weekdayText: "الخميس",
            stories: (0..<5).map { i in
                SavedStory(id: "s3-\(i)", savedDateText: "18/11/2025",
                           avatarAssetName: ["artist_5", "artist_3", "artist_4"][i % 3])
            }
        )
        return [tuesday, wednesday, thursday]
    }

    func fetchTrendingStories() async throws -> [TrendingStory] {
        [
            .init(id: "t1",  displayName: "Ahmed",   avatarAssetName: "artist_3"),
            .init(id: "t2",  displayName: "Nada",    avatarAssetName: "artist_4"),
            .init(id: "t3",  displayName: "Mohamed", avatarAssetName: "artist_5"),
            .init(id: "t4",  displayName: "Mahmoud", avatarAssetName: "artist_3"),
            .init(id: "t5",  displayName: "Salem",   avatarAssetName: "artist_4"),
            .init(id: "t6",  displayName: "Mariam",  avatarAssetName: "artist_5"),
            .init(id: "t7",  displayName: "Maged",   avatarAssetName: "artist_3"),
            .init(id: "t8",  displayName: "Ahmed",   avatarAssetName: "artist_4"),
            .init(id: "t9",  displayName: "Lyly",    avatarAssetName: "artist_5"),
            .init(id: "t10", displayName: "Salma",   avatarAssetName: "artist_3"),
            .init(id: "t11", displayName: "Aya",     avatarAssetName: "artist_4"),
            .init(id: "t12", displayName: "Ahmed",   avatarAssetName: "artist_5"),
        ]
    }
}
