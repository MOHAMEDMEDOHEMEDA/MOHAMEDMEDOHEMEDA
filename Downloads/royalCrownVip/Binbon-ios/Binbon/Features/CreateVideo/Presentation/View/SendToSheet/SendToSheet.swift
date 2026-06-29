//
//  SendToSheet.swift
//  Binbon
//
//  Created by Mrwan Hany on 09/06/2026.
//

import SwiftUI

struct SendToSheet: View {

    var onClose: () -> Void = {}

    @State private var query: String = ""

    private let friends = ["Amira ali", "Soltan Khames", "Hamza Morad",
                           "Eman Ezat", "Amira ali", "Soltan Khames"]

    private let shareTargets: [(String, String)] = [
        ("link", "Copy link"), ("arrowshape.turn.up.right.fill", "Republish"),
        ("f.circle.fill", "Facebook"), ("camera.circle.fill", "instagram"),
        ("music.note", "tiktok"), ("x.circle.fill", "X"),
        ("phone.circle.fill", "whatsapp"), ("paperplane.circle.fill", "telegram"),
        ("message.circle.fill", "messenger"), ("bolt.circle.fill", "snapchat")
    ]

    private let actions: [(String, String)] = [
        ("flag.fill", "Report"), ("heart.slash.fill", "Not interested"),
        ("arrow.down.to.line", "save"), ("star.fill", "add my story"),
        ("megaphone.fill", "promotion"), ("livephoto", "screen Live"),
        ("gift.fill", "Share a gift"), ("photo.stack.fill", "Live images"),
        ("speedometer", "Operating speed"), ("rectangle.and.pencil.and.ellipsis", "Create a poster"),
        ("arrow.triangle.merge", "to merge"), ("character.bubble", "translation"),
        ("questionmark.circle", "Why this video?")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.15))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            SendToSheetHeader(onClose: onClose)

            SendToSheetSearchField(query: $query)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SendToSheetFriendsRow(friends: friends)
                    SendToSheetTargetsGrid(items: shareTargets)
                    SendToSheetTargetsGrid(items: actions)
                }
                .padding(.vertical, 18)
            }
        }
        .background(Color.white)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}
