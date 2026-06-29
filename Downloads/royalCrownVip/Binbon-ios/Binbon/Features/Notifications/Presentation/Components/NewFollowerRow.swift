//
//  NewFollowerRow.swift
//  Binbon
//
//  Created by Husayn on 09/06/2026.
//

import SwiftUI

struct NewFollowerRow: View {
    let follower: NewFollower
    let onFollowBack: () -> Void
    @State private var profileImage: UIImage? = nil

    var body: some View {
        HStack(spacing: 12) {
            
            ProfileImageView.widget(image: profileImage, size: 50, cornerRadius: 10)
                .task {
                    profileImage = await Network.shared.image(follower.imageURL ?? "")
                }

            VStack(alignment: .leading, spacing: 6) {
                Text("followed_you".localizedFormat(follower.name))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.appText)

                Text(follower.timeAgo)
                    .font(.system(size: 11))
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
                    .overlay(Capsule().stroke(.appText.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NewFollowerRow(
        follower: NewFollower(id: 1, name: "Hamza Syria", imageURL: nil, timeAgo: "17 hours ago", isFollowing: false),
        onFollowBack: {}
    )
    .padding()
    .background(Color.purple)
}
