//
//  ActivityFeedRow.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import SwiftUI

struct ActivityFeedRow: View {
    let item: ActivityItem

    var body: some View {
        HStack(spacing: 12) {
            ActivityAvatar(name: item.actorName, imageURL: item.actorImageURL, kind: item.kind)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayLine)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)
                Text(item.timeAgo)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appGold)
            }

            Spacer()

            if let thumbnailURL = item.thumbnailURL, !thumbnailURL.isEmpty {
                ImageView(thumbnailURL)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.appGold.opacity(0.35))
                    .frame(width: 40, height: 40)
            }
        }
    }
}
