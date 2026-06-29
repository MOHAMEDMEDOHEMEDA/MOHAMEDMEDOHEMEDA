//
//  HomeView.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.router) var router
    @Environment(\.storage) var storage
    @State private var showCompleteInfo = false
    @State private var selectedTab: HomeTab = .reels

    // The reels screen auto-hides its overlay chrome; the top pills fade out with
    // it so the video plays uninterrupted. Pills stay put on every other tab.
    @ObservedObject private var reelChrome = ReelChromeState.shared
    
    var body: some View {
        content
            .appBackground()
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .persistentSystemOverlays(.hidden) // Prevents safe area recalculation
            .onAppear { checkForOnboarding() }
            .fullScreenCover(isPresented: $showCompleteInfo) {
                NavigationView { EditProfileView(isPresented: $showCompleteInfo) }
            }
    }
    
    func checkForOnboarding() {
        if storage.user?.newRegister == true {
            showCompleteInfo = true
        } else if storage.user?.onboardingRequired == true,
                  storage.user?.onboardingCompleted == false {
            router.root(.onboard(.step1Singers))
        }
    }
    
    // MARK: - Content
    private var content: some View {
        ZStack(alignment: .top) {
            
            
            TabView(selection: $selectedTab) {
                ReelsView()
                    .tag(HomeTab.reels)
                
                VideosView()
                    .tag(HomeTab.videos)
                
                PhotosView()
                    .tag(HomeTab.photos)

                PostsView()
                    .tag(HomeTab.posts)
                
                ShortsView()
                    .tag(HomeTab.shorts)

                ScrollView(showsIndicators: false) {
                    MyStoriesContent()
                        .padding(.top, 60)
                }
                .tag(HomeTab.story)

                LiveView()
                    .tag(HomeTab.live)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.all)
            
            VStack(spacing: 8) {
                searchHeader
                tabBar
                Spacer()
            }
            .opacity(pillsHidden ? 0 : 1)
            .allowsHitTesting(!pillsHidden)
            .animation(.easeInOut(duration: 0.3), value: pillsHidden)
        }
    }

    /// Pills follow the reels chrome only on the reels tab; everywhere else the
    /// chrome flag is irrelevant and they stay visible.
    private var pillsHidden: Bool {
        selectedTab == .reels && !reelChrome.chromeVisible
    }
    
    // MARK: - Search header
    /// Top row above the feed pills: a rounded search field, a forward chevron and
    /// a notification bell. Matches the search-field style used in the Live tab.
    private var searchHeader: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Text("search".localized)
                    .font(.system(size: 12, weight: .medium))
                
                Spacer()

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 18, height: 18)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.appText)
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.appText.opacity(0.4), lineWidth: 1)
            )

            Button {
                // TODO: forward chevron action — no destination spec yet.
            } label: {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.appText)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.clear)
                    )
            }
            .buttonStyle(.plain)

            Button {
                router.navigate(.activity)
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.appText)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.clear)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("notifications".localized)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(HomeTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.title,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Home Tab Enum
private enum HomeTab: String, CaseIterable {
    case reels
    case videos
    case photos
    case posts
    case story
    case live
    case shorts

    var title: String {
        switch self {
        case .reels: "home_tab_reels".localized
        case .videos: "home_tab_videos".localized
        case .photos: "home_tab_photos".localized
        case .posts: "home_tab_posts".localized
        case .story: "home_tab_story".localized
        case .live: "home_tab_live".localized
        case .shorts: "home_tab_short".localized
        }
    }
}

// MARK: - Tab Button
private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .tracking(-0.22)
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(minWidth: 65, minHeight: 34, maxHeight: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(AppColor.tabBorderGradient, lineWidth: 1)
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .if(isSelected) {
                            $0.fill(AppColor.tabSelectedGradient)
                        } else: {
                            $0.fill(AppColor.tabUnselectedGradient)
                        }
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}
