//
//  StoryEmptyCard.swift
//  Binbon
//
//  Created by Aya Mashaly on 16/06/2026.
//

import SwiftUI

struct StoryEmptyCard: View {

    let avatarAssetName: String?

    @Environment(\.router) private var router

    var body: some View {
        Button {
            router.navigate(.storyViewer(viewerData))
        } label: {
            VStack(spacing: 8) {
                avatarStack
                Text(AppStrings.storyMyToday.localized)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 28)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var viewerData: StoryViewerData {
        let covers = [avatarAssetName, "artist_3", "artist_4"]
        return StoryViewerData(
            authorName: AppStrings.storyMyToday.localized,
            authorAvatarAssetName: avatarAssetName,
            items: covers.enumerated().map { index, cover in
                StoryItem(id: "my-\(index)", coverAssetName: cover, timeAgo: "\(index + 1)h ago")
            }
        )
    }
    
    private var avatarStack: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Circle()
                    .stroke(AppColor.storyRingGradient, lineWidth: 3)
                    .frame(width: 128, height: 128)
                
                avatar
                    .frame(width: 114, height: 114)
                    .clipShape(Circle())
            }
        }
    }
    
    @ViewBuilder
    private var avatar: some View {
        if let avatarAssetName, !avatarAssetName.isEmpty {
            Image(avatarAssetName).resizable().scaledToFill()
        } else {
            Circle().fill(AppColor.sectionSurface)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.appText.opacity(0.4))
                        .font(.system(size: 56))
                }
        }
    }
}
