//
//  NotifLikeCommentBadge.swift
//  Binbon
//
//  Created by Mrwan hany on 03/06/2026.
//

import SwiftUI


struct NotifLikeCommentBadge: View {
    let isLike: Bool

    var body: some View {
        Image(isLike ? "notif-like" : "notif-comment")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: isLike ? 14 : 15, height: isLike ? 14 : 15)
            .foregroundStyle(isLike ? Color(hex: "83489C") : .white)
            .frame(width: 24, height: 24)
            .background(isLike ? Color.appGold : Color(hex: "4CD964"), in: Circle())
    }
}
