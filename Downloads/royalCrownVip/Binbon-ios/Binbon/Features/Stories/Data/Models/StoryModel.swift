//
//  StoryModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 16/06/2026.
//

import Foundation

// MARK: - Story tabs
enum StoryTab: String, CaseIterable, Hashable, Identifiable {
    case my
    case trending
    case friends
    case following
    case followers
    case saved
    
    var id: String { rawValue }
    
    var titleKey: String {
        switch self {
        case .my:        AppStrings.storyTabMy
        case .trending:  AppStrings.storyTabTrending
        case .friends:   AppStrings.storyTabFriends
        case .following: AppStrings.storyTabFollowing
        case .followers: AppStrings.storyTabFollowers
        case .saved:     AppStrings.storyTabSaved
        }
    }

    var usesGridLayout: Bool { gridBadgeAssetName != nil }

    var gridBadgeAssetName: String? {
        switch self {
        case .trending:  "story-trending-badge"
        case .friends:   "story-friends-badge"
        case .following: "story-following-badge"
        case .followers: "story-followers-badge"
        default:         nil
        }
    }
}

// MARK: - Quick-action pills under the profile header
enum StoryQuickPill: String, CaseIterable, Hashable, Identifiable {
    case clips
    case video
    case photo
    case story
    case save
    case live
    
    var id: String { rawValue }
    
    var titleKey: String {
        switch self {
        case .clips: AppStrings.storyPillClips
        case .video: AppStrings.storyPillVideo
        case .photo: AppStrings.storyPillPhoto
        case .story: AppStrings.storyPillStory
        case .save:  AppStrings.storyPillSave
        case .live:  AppStrings.storyPillLive
        }
    }
}

// MARK: - Profile summary shown on the Stories screen header
struct ProfileSummary: Hashable, Decodable {
    let displayName: String
    let binbonId: String
    let zodiacLabel: String
    let avatarAssetName: String?
    let coverAssetName: String?
    let coverCaption: String
    let likesText: String
    let followersText: String
    let followingText: String
    let isVerified: Bool
}

// MARK: - Friend with active story
struct StoryFriend: Identifiable, Hashable, Decodable {
    let id: String
    let displayName: String
    let avatarAssetName: String?
}

// MARK: - Story content for a given tab
struct Story: Identifiable, Hashable, Decodable {
    let id: String
    let title: String
    let coverAssetName: String?
}

// MARK: - Trending story card
struct TrendingStory: Identifiable, Hashable, Decodable {
    let id: String
    let displayName: String
    let avatarAssetName: String?
}

// MARK: - Saved story item (a single story I bookmarked)
struct SavedStory: Identifiable, Hashable, Decodable {
    let id: String
    let savedDateText: String
    let avatarAssetName: String?
}

// A horizontal row of saved stories sharing the same calendar day.
struct SavedStoryGroup: Identifiable, Hashable, Decodable {
    let id: String
    let dateText: String
    let weekdayText: String
    let stories: [SavedStory]
}

// MARK: - Save my Story
struct SaveMyStoryDay: Identifiable, Hashable, Decodable {
    let id: String
    let titleKey: String
    let dateText: String?
    let captionKey: String
    let bodyDateText: String
}

// MARK: - Story viewer
struct StoryItem: Identifiable, Hashable, Decodable {
    let id: String
    let coverAssetName: String?
    let timeAgo: String
}

struct StoryViewerData: Hashable, Decodable {
    let authorName: String
    let authorAvatarAssetName: String?
    let items: [StoryItem]
}
