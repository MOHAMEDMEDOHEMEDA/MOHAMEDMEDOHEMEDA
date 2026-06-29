//
//  ProfileVideoChannels.swift
//  Binbon
//
//  The profile "Video" category: a folder-tab "union" (Celebrity / My Channel /
//  Subscribed) — same shape as the Live/Comments tabs, blended into the screen
//  background — over either a list of video rows or, for Subscribed Channels, a
//  list of channel rows.
//

import SwiftUI

// MARK: - Models
struct ProfileVideoItem: Identifiable {
    let id = UUID()
    let thumbnail: String
    let views: String
    let avatar: String
    let username: String
    let badge: String
    let title: String
    let subtitle: String
}

struct ProfileChannelItem: Identifiable {
    let id = UUID()
    let avatar: String
    let name: String
}

enum VideoChannelTab: CaseIterable, Identifiable {
    case celebrity, myChannel, subscribed

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .celebrity:  "celebrity_videos"
        case .myChannel:  "my_channel_videos"
        case .subscribed: "subscribed_channels"
        }
    }
}

// MARK: - Content
struct ProfileVideoChannelsContent: View {

    @State private var selectedTab: VideoChannelTab = .myChannel
    @State private var menuChannelID: UUID?

    private let earHeight: CGFloat = 60

    private var selectedIndex: Int {
        VideoChannelTab.allCases.firstIndex(of: selectedTab) ?? 0
    }

    /// Reversed brand gradient used behind the subscribed-channels list.
    private var subscribedGradient: LinearGradient {
        LinearGradient(
            colors: [AppColor.gradientEnd, AppColor.gradientStart],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var unionFill: AnyShapeStyle {
        selectedTab == .subscribed
            ? AnyShapeStyle(subscribedGradient)
            : AnyShapeStyle(AppColor.backgroundGradient)
    }

    private let videos: [ProfileVideoItem] = [
        .init(thumbnail: "media-reel-2", views: "15K",  avatar: "media-photo-1",
              username: "@noor.creates", badge: "🌹",
              title: "Q&A with you", subtitle: "Shot entirely on mobile."),
        .init(thumbnail: "media-reel-3", views: "984",  avatar: "media-photo-2",
              username: "@amir.films", badge: "🌹",
              title: "My morning routine", subtitle: "New episodes every week"),
        .init(thumbnail: "media-reel-1", views: "2.3K", avatar: "media-photo-3",
              username: "@layla.codes", badge: "✨",
              title: "Behind the scenes", subtitle: "Raw and unfiltered")
    ]

    private let channels: [ProfileChannelItem] = [
        .init(avatar: "media-photo-1", name: "Samir mokhtar"),
        .init(avatar: "media-reel-2",  name: "Mo shaaban"),
        .init(avatar: "media-reel-3",  name: "nermin elqady"),
        .init(avatar: "media-photo-3", name: "Refaey Eldosouqy"),
        .init(avatar: "media-reel-1",  name: "Shahd Maged"),
        .init(avatar: "media-photo-2", name: "Cook with Nora")
    ]

    var body: some View {
        VStack(spacing: 0) {
            tabLabelRow

            content
                .padding(.top, 12)
                .padding(.bottom, 16)
        }
        .background {
            CommentsUnionBackground(
                selectedIndex: selectedIndex,
                count: VideoChannelTab.allCases.count,
                earHeight: earHeight,
                fill: unionFill,
                strokeBottom: false
            )
        }
        .overlay { menuScrim }
        .overlayPreferenceValue(ChannelDotsAnchorKey.self) { anchors in
            channelMenu(anchors: anchors)
        }
        .animation(.easeInOut(duration: 0.18), value: menuChannelID)
//        .padding(.horizontal, 8)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var menuScrim: some View {
        if menuChannelID != nil {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { menuChannelID = nil }
        }
    }

    @ViewBuilder
    private func channelMenu(anchors: [UUID: Anchor<CGPoint>]) -> some View {
        GeometryReader { proxy in
            if let id = menuChannelID, let anchor = anchors[id] {
                let point = proxy[anchor]
                ChannelOptionsMenu(
                    onMute: { menuChannelID = nil },
                    onBlock: { menuChannelID = nil }
                )
                .offset(x: point.x - 230, y: point.y + 6)
                .transition(.scale(scale: 0.9, anchor: .topTrailing).combined(with: .opacity))
            }
        }
    }

    // MARK: Folder tab labels (drawn over the union background)
    private var tabLabelRow: some View {
        HStack(spacing: 0) {
            ForEach(VideoChannelTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    Text(tab.titleKey.localized)
                        .font(.system(size: 14, weight: selectedTab == tab ? .bold : .semibold))
                        .foregroundStyle(.appText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: earHeight)
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .subscribed:
            channelsList
        default:
            videoList
        }
    }

    private var videoList: some View {
        LazyVStack(spacing: 0) {
            ForEach(videos) { item in
                ProfileVideoRow(item: item)
                Divider().overlay(Color.appText.opacity(0.12))
            }
        }
    }

    private var channelsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(channels) { channel in
                ProfileChannelRow(channel: channel) { menuChannelID = channel.id }
                Divider().overlay(Color.appText.opacity(0.10))
            }
        }
    }
}

// MARK: - Channel options anchor + popup

struct ChannelDotsAnchorKey: PreferenceKey {
    static var defaultValue: [UUID: Anchor<CGPoint>] = [:]
    static func reduce(value: inout [UUID: Anchor<CGPoint>], nextValue: () -> [UUID: Anchor<CGPoint>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private struct ChannelOptionsMenu: View {
    var onMute: () -> Void = {}
    var onBlock: () -> Void = {}

    private var gradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "E5895F"), Color(hex: "D86E6F")],
                       startPoint: .top, endPoint: .bottom)
    }

    var body: some View {
        VStack(spacing: 0) {
            row("mute".localized, systemImage: "bell.slash.fill", action: onMute)
            Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
            row("block".localized, systemImage: "nosign", action: onBlock)
        }
        .frame(width: 230)
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 14, y: 6)
    }

    private func row(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .regular))
                Spacer()
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Video row
private struct ProfileVideoRow: View {
    let item: ProfileVideoItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            thumbnail
            infoColumn
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var thumbnail: some View {
        Color.clear
            .frame(width: 150, height: 150)
            .overlay {
                Image(item.thumbnail)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColor.gold, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.black.opacity(0.35)))
                    .padding(8)
            }
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill").font(.system(size: 11))
                    Text(item.views).font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.4), radius: 2)
                .padding(8)
            }
    }

    private var infoColumn: some View {
        VStack(alignment: .leading, spacing: 14) {
            chevronRow {
                Image(item.avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                Text(item.username)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.appText)
                    .lineLimit(1)
                Text(item.badge).font(.system(size: 13))
            }

            chevronRow {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.appText)
                    .lineLimit(1)
            }

            chevronRow {
                Text(item.subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.appText.opacity(0.6))
                    .lineLimit(1)
            }

            chevronRow {
                Image("cs-gift")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("content_support".localized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.gold)
                    .lineLimit(1)
            }
        }
    }

    private func chevronRow<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 6) {
            content()
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.appText.opacity(0.6))
        }
    }
}

// MARK: - Channel row
private struct ProfileChannelRow: View {
    let channel: ProfileChannelItem
    var onOptions: () -> Void = {}

    var body: some View {
        HStack(spacing: 14) {
            Image(channel.avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColor.gold, lineWidth: 2))

            Text(channel.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 8)

            Button {
                // TODO: unsubscribe — no spec yet.
            } label: {
                Text("unsubscribe".localized)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.appText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white.opacity(0.15)))
            }
            .buttonStyle(.plain)

            Button(action: onOptions) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.appText)
                    .frame(width: 24, height: 32)
                    .contentShape(Rectangle())
                    .anchorPreference(key: ChannelDotsAnchorKey.self, value: .bottom) {
                        [channel.id: $0]
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}
