//
//  NotifMessageRow.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifMessagesHeader: View {
    let isAllSelected: Bool
    let onToggleSelectAll: () -> Void
    let onMarkAllRead: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggleSelectAll) {
                HStack(spacing: 8) {
                    NotifCheckbox(isOn: isAllSelected)
                    Text("select_all".localized)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.appText.opacity(0.85))
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onMarkAllRead) {
                HStack(spacing: 6) {
                    NotifIcon(name: "notif-message-alt", color: Color.appGold, size: 22)
                    
                    Text("mark_as_read".localized)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.appText.opacity(0.85))
          
                }
            }
        }
        .padding(.bottom, 4)
    }
}

struct NotifMessageRow: View {
    let item: NotificationItem
    let onToggleRead: () -> Void

    private var isRead: Bool { !item.isUnread }

    var body: some View {
        HStack(spacing: 12) {
            NotifAvatar(name: item.actorName, imageURL: item.avatarURL)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title ?? "")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)

                HStack(spacing: 8) {
                    Text(item.timeAgo ?? "")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.appGold)
                    Spacer()
                    HStack(spacing: 10) {
                        Text(isRead ? "read".localized : "unread".localized)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(isRead ? Color.appText : Color.appGold)

                        Button(action: onToggleRead) {
                            NotifMessageIcon()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()
        }
    }
}
