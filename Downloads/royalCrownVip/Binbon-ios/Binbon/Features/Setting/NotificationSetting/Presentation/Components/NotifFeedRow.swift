//
//  NotifFeedRow.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifFeedRow<Accessory: View>: View {
    let item: NotificationItem
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        HStack(spacing: 12) {
            NotifAvatar(name: item.actorName, imageURL: item.avatarURL)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title ?? "")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)
                Text(item.timeAgo ?? "")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appGold)
            }

            Spacer()

            accessory()
        }
    }
}
