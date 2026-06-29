//
//  StoryFriendsStrip.swift
//  Binbon
//
//  Created by Aya Mashaly on 16/06/2026.
//

import SwiftUI

struct StoryFriendsStrip: View {

    let friends: [StoryFriend]

    @Environment(\.router) private var router

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(friends) { friend in
                    Button {
                        router.navigate(.storyViewer(viewerData(for: friend)))
                    } label: {
                        cell(for: friend)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 19)
        }
    }

    private func cell(for friend: StoryFriend) -> some View {
        VStack(spacing: 10) {
            StoryAvatar(
                assetName: friend.avatarAssetName,
                ringSize: 64,
                imageSize: 60,
                ringStyle: AppColor.storyRingGradient
            )

            Text(friend.displayName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 59)
        }
        .frame(width: 59)
        .padding(.top, 10)
        .accessibilityElement(children: .combine)
    }

    private func viewerData(for friend: StoryFriend) -> StoryViewerData {
        let covers = [friend.avatarAssetName, "artist_4", "artist_5"]
        return StoryViewerData(
            authorName: friend.displayName,
            authorAvatarAssetName: friend.avatarAssetName,
            items: covers.enumerated().map { index, cover in
                StoryItem(id: "\(friend.id)-\(index)", coverAssetName: cover, timeAgo: "\(2 + index)h ago")
            }
        )
    }
}
