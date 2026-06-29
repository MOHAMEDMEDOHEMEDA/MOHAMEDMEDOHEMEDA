//
//  FriendsView.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//
//  Friends list — the audience picker opened from "Followers can view this
//  post". Header count + scrollable rows. Themed + localized + RTL-safe.
//

import SwiftUI

struct FriendsView: View {

    var onClose: () -> Void = {}

    @ObservedObject private var theme = ThemeManager.shared
    @StateObject private var viewModel = FriendsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.friends) { friend in
                        FriendRow(friend: friend)
                        Divider().overlay(Color.appText.opacity(0.12))
                    }
                }
                .padding(.horizontal, 20)
            }
            .adaptiveContentWidth()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appBackground()
            .appNavigation(title: viewModel.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.appText)
                    }
                }
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear { viewModel.load() }
    }
}

private struct FriendRow: View {

    let friend: Friend

    var body: some View {
        HStack(spacing: 12) {
            avatar
            Text(friend.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.appText)
            Spacer()
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        Circle()
            .fill(AppColor.buttonGradient)
            .frame(width: 48, height: 48)
            .overlay(
                Text(String(friend.name.prefix(1)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            )
    }
}

#Preview {
    FriendsView()
}

#Preview("RTL") {
    FriendsView()
        .environment(\.layoutDirection, .rightToLeft)
}
