//
//  GameAchievementRow.swift
//  Binbon
//
//  One achievement card: details + game name on the leading side,
//  the game thumbnail on the trailing side (mirrors automatically in RTL).
//

import SwiftUI

struct GameAchievementRow: View {
    let achievement: GameAchievement
    

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.details)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(achievement.gameName)
                    .font(.caption)
                    .foregroundStyle(.appText.opacity(0.7))
            }

            Spacer(minLength: 8)

            thumbnail
        }
        .padding(.vertical, 4)
    }

    private var thumbnail: some View {
        Group {
            if let assetName = achievement.assetName, !assetName.isEmpty {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else if let url = achievement.thumbnailURL, !url.isEmpty {
                ImageView(url)
            } else {
                Image(systemName: "gamecontroller.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColor.buttonGradient)
            }
        }
        .frame(width: 54, height: 54)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
