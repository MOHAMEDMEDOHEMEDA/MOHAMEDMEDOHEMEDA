//
//  ProfileView + Tabs.swift
//  Binbon
//
//  Created by Salah Khaled on 28/04/2026.
//

import SwiftUI

/// Published by the profile scroll view so the header can collapse with scroll.
struct ProfileScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// The scrollable profile body (tabs + media grids). Isolated into its own view
/// so the collapsing header's per-frame `scrollOffset` updates don't re-evaluate
/// this (heavy) subtree — only its stable inputs would. Keeps scrolling smooth.
struct ProfileScrollContent: View {
    @Binding var selectedTab: Int
    /// Spacer that reserves room for the expanded header above the tabs.
    let headerSpacerHeight: CGFloat

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear.frame(height: headerSpacerHeight)

                VStack(spacing: 0) {
                    ProfileTabBar(tabs: allTabs, selectedIndex: $selectedTab)
                        .padding(.top, 16)

                    ProfileTabView(tab: allTabs[selectedTab])
                        .animation(.easeInOut(duration: 0.25), value: selectedTab)

                    VStack {}
                        .frame(height: 50)
                }
            }
            .foregroundStyle(.appText)
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ProfileScrollOffsetKey.self,
                            value: -geo.frame(in: .named("scroll")).minY
                        )
                }
            )
        }
        .coordinateSpace(name: "scroll")
    }
}


// MARK: - Profile Tab Bar
private struct ProfileTabBar: View {
    let tabs: [TabData]
    @Binding var selectedIndex: Int
    // Repaint the tab icons on any theme switch (incl. Colored↔Dark).
    @ObservedObject private var theme = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIndex = index
                    }
                } label: {
                    Image(systemName: tab.icon)
                        .symbolVariant(selectedIndex == index ? .fill : .none)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(selectedIndex == index
                                         ? AnyShapeStyle(Color.appText)
                                         : AnyShapeStyle(AppColor.goldAccentGradient))
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background {
                            if selectedIndex == index {
                                LinearGradient(
                                    colors: [AppColor.gradientEnd, AppColor.gradientStart],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .clipShape(segmentShape(index: index, count: tabs.count))
                            }
                        }
                }

                if index != tabs.count - 1 {
                    Divider()
                        .frame(width: 2)
                        .background(AppColor.goldAccentGradient)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColor.goldAccentGradient, lineWidth: 1.5)
        )
        .padding(.horizontal, 16)
    }

    /// Rounds the outer corners of the first/last segment so the selected fill
    /// matches the container; middle segments stay square.
    private func segmentShape(index: Int, count: Int) -> UnevenRoundedRectangle {
        let radius: CGFloat = 13
        return UnevenRoundedRectangle(
            topLeadingRadius: index == 0 ? radius : 0,
            bottomLeadingRadius: index == 0 ? radius : 0,
            bottomTrailingRadius: index == count - 1 ? radius : 0,
            topTrailingRadius: index == count - 1 ? radius : 0,
            style: .continuous
        )
    }
}

// MARK: - Profile Tab View
struct ProfileTabView: View {
    let tab: TabData
    @State private var selectedCategory: MediaCategory?

    var filteredItems: [MediaItem] {
        tab.items
    }

    var body: some View {
        VStack(spacing: 0) {
            CategoryList(
                categories: tab.categories,
                selectedCategory: $selectedCategory,
                onSelect: select
            )
            .padding(.top, 12)
            .onAppear {
                if selectedCategory == nil { selectedCategory = tab.categories.first }
            }

            switch selectedCategory?.name {
            case "cat_story":
                MyStoriesContent()
            case "cat_save_my_story":
                SaveMyStoryContent()
            case "cat_video", "cat_videos":
                ProfileVideoChannelsContent()
            default:
                MediaGrid(items: filteredItems)
            }
        }
    }
    
    private func select(_ category: MediaCategory) {
        withAnimation(.easeInOut(duration: 0.15)) {
            selectedCategory = category
        }
    }
}


// MARK: - Category List
private struct CategoryList: View {
    let categories: [MediaCategory]
    @Binding var selectedCategory: MediaCategory?
    var onSelect: (MediaCategory) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { cat in
                    CategoryPill(
                        name: cat.name,
                        isSelected: selectedCategory?.id == cat.id
                    ) {
                        onSelect(cat)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
    
    private struct CategoryPill: View {
        let name: String
        let isSelected: Bool
        let action: () -> Void
        @ObservedObject private var theme = ThemeManager.shared
        
        var body: some View {
            Button(action: action) {
                Text(name.localized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.appText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .stroke(AppColor.goldAccentGradient, lineWidth: 1.5)
                            .background(
                                Capsule()
                                    .fill(isSelected
                                          ? Color.appGold.opacity(0.2)
                                          : Color.clear)
                            )
                    )
            }
        }
    }
}


// MARK: - Media Grid
struct MediaGrid: View {
    let items: [MediaItem]
    var cornerBadge: MediaCornerBadge = .none
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(items) { item in
                MediaCard(item: item, cornerBadge: cornerBadge)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}


// MARK: - Media Card
struct MediaCard: View {
    let item: MediaItem
    var cornerBadge: MediaCornerBadge = .none

    @ObservedObject private var theme = ThemeManager.shared
    
    var body: some View {
        // A clear container drives the cell size (so every tile is equal); the
        // thumbnail fills it as an overlay and is clipped to the rounded card.
        Color.clear
            .aspectRatio(106 / 172, contentMode: .fit)
            .overlay {
                Image(item.assetName)
                    .resizable()
                    .scaledToFill()
            }
            .overlay(AppColor.mediaTileOverlay)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppColor.gold, lineWidth: 2)
            )
            // Top-left badge (bookmark on Saved, heart on Liked).
            .overlay(alignment: .topLeading) {
                if let badge = cornerBadgeSymbol {
                    Image(systemName: badge)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2)
                        .padding(8)
                }
            }
            // Play badge top-right.
            .overlay(alignment: .topTrailing) {
                if item.isVideo {
                    playBadge.padding(6)
                }
            }
            // Views (eye + count) bottom-left.
            .overlay(alignment: .bottomLeading) {
                if item.views != "—" {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 10))
                        Text(item.views)
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.4), radius: 2)
                    .padding(8)
                }
            }
            // Lock badge bottom-right (private items).
            .overlay(alignment: .bottomTrailing) {
                if item.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.4), radius: 2)
                        .padding(8)
                }
            }
    }

    private var cornerBadgeSymbol: String? {
        switch cornerBadge {
        case .none:     nil
        case .bookmark: "bookmark.fill"
        case .heart:    "heart.fill"
        }
    }

    /// Translucent circle with a white play glyph, matching the design's badge.
    private var playBadge: some View {
        Image(systemName: "play.fill")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 20, height: 20)
            .background(Circle().fill(Color.black.opacity(0.35)))
    }
}
