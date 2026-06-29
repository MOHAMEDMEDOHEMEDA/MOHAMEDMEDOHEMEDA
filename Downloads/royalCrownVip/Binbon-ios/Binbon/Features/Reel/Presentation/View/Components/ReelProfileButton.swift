//
//  ReelProfileButton.swift
//  Binbon
//

import SwiftUI

struct ReelProfileButton: View {
    let avatarURL: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ImageView(avatarURL)
                .frame(width: 46, height: 46)
                .clipShape(Circle())
                .overlay { Circle().stroke(Color.appGold, lineWidth: 2) }
                .shadow(color: .black.opacity(0.6), radius: 8)
                .overlay(alignment: .bottom) { sendBadge.offset(y: 11) }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var sendBadge: some View {
        Image("reels-share")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 11, height: 11)
            .foregroundStyle(.white)
            .frame(width: 22, height: 22)
            .background(Circle().fill(AppColor.shareCopyLinkGradient))
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
    }
}
