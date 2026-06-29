//
//  ActivityKindBadge.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import SwiftUI

struct ActivityKindBadge: View {
    let kind: ActivityKind

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 20, height: 20)

            icon
        }
        .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 1))
    }

    @ViewBuilder
    private var icon: some View {
        switch kind {
        case .follow:
            Image(systemName: "plus")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)

        case .like:
            Image("notif-like")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundStyle(.white)

        case .comment:
            Image("notif-comment")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 11, height: 11)
                .foregroundStyle(.white)

        case .mention:
            Image(systemName: "at")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)

        case .live, .system:
            Image(systemName: "bell.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private var backgroundColor: Color {
        switch kind {
        case .follow:
            Color(hex: "83489C")   // purple
        case .like, .comment:
            Color(hex: "E14554")   // red
        case .mention:
            Color.appGold          // yellow/orange
        case .live:
            .red
        case .system:
            Color(hex: "83489C")
        }
    }
}
