//
//  NotifFollowerRow.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI


struct NotifFollowerRow: View {
    let item: NotificationItem
    let onFollow: () -> Void
    let onUnfollow: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            NotifAvatar(name: item.actor?.fullname ?? "", imageURL: item.avatarURL)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title ?? "")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)
                Text(item.timeAgo ?? "")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.appGold)
            }
            
            Spacer()

            let isFollowing = item.isFollowing ?? false
            Button(action: isFollowing ? onUnfollow : onFollow) {
                NotifFollowPill(isFollowing: isFollowing)
            }
            .buttonStyle(.plain)
        }
    }
}
