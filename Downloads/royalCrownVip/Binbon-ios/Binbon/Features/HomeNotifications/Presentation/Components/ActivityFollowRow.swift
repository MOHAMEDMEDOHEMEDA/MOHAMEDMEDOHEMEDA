//
//  ActivityFollowRow.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import SwiftUI

struct ActivityFollowRow: View {
    let item: ActivityItem
    let onFollowBack: () -> Void

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

            Button(action: onFollowBack) {
                Text("follow_back".localized)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(AppColor.buttonGradient, in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}
