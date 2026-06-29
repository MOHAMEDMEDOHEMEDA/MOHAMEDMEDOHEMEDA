//
//  NotifFollowPill.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI

struct NotifFollowPill: View {
    let isFollowing: Bool
    var body: some View {
        Text(isFollowing ? "unfollow".localized : "follow".localized)
            .font(.caption.weight(.bold))
            .foregroundStyle(.appText)
            .padding(.horizontal, 18)
            .padding(.vertical, 7)
            .background(AppColor.chromeButtonGradient, in: Capsule())
            .overlay(Capsule().stroke(.appText.opacity(0.3), lineWidth: 1))
    }
}
