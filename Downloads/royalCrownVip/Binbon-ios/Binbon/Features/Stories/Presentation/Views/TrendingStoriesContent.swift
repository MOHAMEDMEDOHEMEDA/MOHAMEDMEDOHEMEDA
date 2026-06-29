//
//  TrendingStoriesContent.swift
//  Binbon
//
//  Created by Aya Mashaly on 17/06/2026.
//

import SwiftUI

struct TrendingStoriesContent: View {

    let titleKey: String
    let stories: [TrendingStory]
    let badgeAssetName: String

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 8, alignment: .top),
        count: 4
    )

    var body: some View {
        VStack(spacing: 16) {
            Text(titleKey.localized)
                .font(.system(size: 14, weight: .bold))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(stories) { story in
                    TrendingStoryCard(story: story, badgeAssetName: badgeAssetName)
                }
            }
            .padding(.horizontal, 19)
        }
        .padding(.top, 12)
    }
}

private struct TrendingStoryCard: View {

    let story: TrendingStory
    let badgeAssetName: String

    @Environment(\.router) private var router

    var body: some View {
        Button {
            router.navigate(.storyViewer(viewerData))
        } label: {
            cardBody
        }
        .buttonStyle(.plain)
    }

    private var viewerData: StoryViewerData {
        let covers = [story.avatarAssetName, "artist_3"]
        return StoryViewerData(
            authorName: story.displayName,
            authorAvatarAssetName: story.avatarAssetName,
            items: covers.enumerated().map { index, cover in
                StoryItem(id: "\(story.id)-\(index)", coverAssetName: cover, timeAgo: "\(3 + index)h ago")
            }
        )
    }

    private var cardBody: some View {
        VStack(spacing: 6) {
            StoryAvatar(
                assetName: story.avatarAssetName,
                ringSize: 64,
                ringStyle: AppColor.storyRingGradient
            )
            .overlay(alignment: .bottomTrailing) {
                Image(badgeAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 26)
                    .offset(x: 6, y: 2)
            }

            Text(story.displayName)
                .font(.system(size: 14, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(AppColor.gold, lineWidth: 1)
        }
    }
}
