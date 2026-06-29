//
//  SavedStoriesContent.swift
//  Binbon
//
//  Created by Aya Mashaly on 17/06/2026.
//

import SwiftUI

struct SavedStoriesContent: View {

    let titleKey: String
    let groups: [SavedStoryGroup]

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 6, alignment: .top),
        count: 5
    )

    var body: some View {
        VStack(spacing: 0) {
            Text(titleKey.localized)
                .font(.system(size: 14, weight: .bold))
                .padding(.top, 12)
                .padding(.bottom, 16)

            ForEach(groups) { group in
                groupSection(group)
            }
        }
    }

    @ViewBuilder
    private func groupSection(_ group: SavedStoryGroup) -> some View {
        VStack(spacing: 14) {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(group.stories) { story in
                    SavedStoryCard(story: story)
                }
            }
            .padding(.horizontal, 12)

            HStack(spacing: 4) {
                Text(group.dateText)
                Text(group.weekdayText)
            }
            .font(.system(size: 14, weight: .bold))
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColor.gold)
                .frame(height: 2)
        }
    }
}

private struct SavedStoryCard: View {

    let story: SavedStory

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
        StoryViewerData(
            authorName: "Saeed Ahmed",
            authorAvatarAssetName: story.avatarAssetName,
            items: [StoryItem(id: story.id, coverAssetName: story.avatarAssetName, timeAgo: story.savedDateText)]
        )
    }

    private var cardBody: some View {
        VStack(spacing: 4) {
            StoryAvatar(
                assetName: story.avatarAssetName,
                ringStyle: AppColor.storyRingGradient,
                fallbackGlyphSize: 20
            )
            .overlay(alignment: .bottomTrailing) {
                Image("story-saved-badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 19)
                    .offset(x: 2, y: 0)
            }

            Text(story.savedDateText)
                .font(.system(size: 11, weight: .bold))
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
