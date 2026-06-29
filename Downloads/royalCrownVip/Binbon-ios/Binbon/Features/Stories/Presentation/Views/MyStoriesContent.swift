//
//  MyStoriesContent.swift
//  Binbon
//
//  Created by Aya Mashaly on 16/06/2026.
//

import SwiftUI

struct MyStoriesContent: View {
    
    @StateObject private var viewModel = MyStoriesViewModel()
    
    var body: some View {
        VStack(spacing: 18) {
            
            StoryFriendsStrip(friends: viewModel.friends)
            
            VStack(spacing: 0) {
                StoryTabsBar(selection: $viewModel.selectedTab) { tab in
                    viewModel.select(tab: tab)
                }
                tabContent
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 50)
        .padding(.bottom, 24)
        .onAppear { viewModel.loadInitial() }
    }
    
    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .my:
            StoryEmptyCard(avatarAssetName: viewModel.profile?.avatarAssetName)
                .padding(.vertical, 24)
        case .trending, .friends, .following, .followers:
            TrendingStoriesContent(
                titleKey: viewModel.selectedTab.titleKey,
                stories: viewModel.trending,
                badgeAssetName: viewModel.selectedTab.gridBadgeAssetName ?? "story-trending-badge"
            )
        case .saved:
            SavedStoriesContent(
                titleKey: viewModel.selectedTab.titleKey,
                groups: viewModel.savedGroups
            )
        }
    }
}
