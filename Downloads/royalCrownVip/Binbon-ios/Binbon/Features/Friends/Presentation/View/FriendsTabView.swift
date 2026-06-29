//
//  FriendsTabView.swift
//  Binbon
//
//  Friends bottom-tab screen: a list of people with a Following pill and a
//  three-dot menu that opens a Block / Report / Mute action popover.
//

import SwiftUI

struct FriendsTabView: View {

    @Environment(\.router) private var router
    @Environment(\.layoutDirection) private var layoutDirection
    @StateObject private var viewModel = FriendsTabViewModel()
    @ObservedObject private var theme = ThemeManager.shared
    @State private var reportFriend: FriendItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("friends".localized)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 18) {
                    ForEach(viewModel.friends) { friend in
                        FriendTabRow(friend: friend, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
        }
        .adaptiveContentWidth()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .sheet(item: $reportFriend) { friend in
            NavigationStack {
                FriendReportReasonsView(friend: friend)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
        // Floats the open row's action menu above the list, anchored under its
        // three-dot button.
        .overlayPreferenceValue(FriendMenuAnchorKey.self) { anchor in
            GeometryReader { proxy in
                if let anchor, let openID = viewModel.openMenuFriendID {
                    let rect = proxy[anchor]
                    let menuWidth: CGFloat = 240
                    let menuX = layoutDirection == .rightToLeft
                        ? rect.minX
                        : rect.maxX - menuWidth
                    let scaleAnchor: UnitPoint = layoutDirection == .rightToLeft ? .topLeading : .topTrailing

                    ZStack(alignment: .topLeading) {
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture { withAnimation(.easeOut(duration: 0.15)) { viewModel.closeMenu() } }

                        FriendActionMenu(
                            onBlock: { withAnimation(.easeOut(duration: 0.15)) { viewModel.block(openID) } },
                            onReport: {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    if let friend = viewModel.report(openID) {
                                        reportFriend = friend
                                    }
                                }
                            },
                            onMute: { withAnimation(.easeOut(duration: 0.15)) { viewModel.mute(openID) } }
                        )
                        .frame(width: menuWidth)
                        .offset(x: menuX, y: rect.maxY + 8)
                        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: scaleAnchor)))
                    }
                }
            }
        }
        .preferredColorScheme(theme.preferredColorScheme)
        .onAppear { viewModel.load() }
    }
}

// MARK: - Row

private struct FriendTabRow: View {

    let friend: FriendItem
    @ObservedObject var viewModel: FriendsTabViewModel

    private var isMenuOpen: Bool { viewModel.openMenuFriendID == friend.id }

    var body: some View {
        HStack(spacing: 12) {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text(friend.username)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.appText)
                    .lineLimit(1)

                Text(friend.displayName)
                    .font(.system(size: 14))
                    .foregroundStyle(.appText.opacity(0.7))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            followButton

            menuButton
        }
        .contentShape(Rectangle())
    }

    private var avatar: some View {
        Circle()
            .fill(AppColor.buttonGradient)
            .frame(width: 56, height: 56)
            .overlay(
                Text(String(friend.username.prefix(1)).uppercased())
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            )
    }

    private var followButton: some View {
        Button {
            viewModel.toggleFollow(friend.id)
        } label: {
            Text(friend.isFollowing ? "following".localized : "follow".localized)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.appText)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(.thinMaterial.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.appText.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var menuButton: some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) { viewModel.toggleMenu(for: friend.id) }
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.appText)
                .frame(width: 32, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Anchor the floating menu to this button when it's the open row.
        .anchorPreference(key: FriendMenuAnchorKey.self, value: .bounds) {
            isMenuOpen ? $0 : nil
        }
    }
}

// MARK: - Action menu

private struct FriendActionMenu: View {
    let onBlock: () -> Void
    let onReport: () -> Void
    let onMute: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            row(icon: "nosign", title: "block".localized, tint: AppColor.destructive, action: onBlock)
            divider
            row(icon: "flag", title: "report".localized, tint: .white, action: onReport)
            divider
            row(icon: "speaker.slash.fill", title: "mute".localized, tint: .white, action: onMute)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.contextMenuSurface)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
            .padding(.horizontal, 14)
    }

    private func row(icon: String, title: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(tint)
                    .frame(width: 26, alignment: .center)

                Text(title)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(tint)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Menu anchor preference

private struct FriendMenuAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

#Preview {
    FriendsTabView()
}
