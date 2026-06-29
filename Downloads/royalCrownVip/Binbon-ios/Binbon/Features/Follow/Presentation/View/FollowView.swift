//
//  FollowTab.swift
//  Binbon
//
//  Created by Salah Khaled on 29/04/2026.
//

import SwiftUI
import Combine

struct FollowView: View {
    
    let initialTab: FollowTab
    
    @StateObject private var viewModel = FollowViewModel()
    @State  private var selectedTab: FollowTab
    
    init(initialTab: FollowTab) {
        self.initialTab = initialTab
        _selectedTab = State(initialValue: initialTab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            FollowTabBar(selectedTab: $selectedTab)
            
            Divider().background(.appText.opacity(0.7))
            
            TabView(selection: $selectedTab) {
                FollowFriendsView(viewModel: viewModel)
                    .tag(FollowTab.friends)

                FollowingView(viewModel: viewModel)
                    .tag(FollowTab.following)

                FollowersView(viewModel: viewModel)
                    .tag(FollowTab.followers)

                LikesView(viewModel: viewModel)
                    .tag(FollowTab.likes)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .appNavigation(title: Storage.shared.user?.fullname)
        .appBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedTab) { old, new in
            dismissKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.loadIfNeeded(for: new)
            }
        }
        .onAppear {
            viewModel.loadIfNeeded(for: initialTab)
        }
    }
}

// MARK: - Tab Bar
private struct FollowTabBar: View {
    
    @Binding var selectedTab: FollowTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(FollowTab.allCases, id: \.self) { tab in
                TabBarButton(
                    title: tab.title,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal)
    }
    
    private struct TabBarButton: View {
        
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 6) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? AppColor.gold : .appText.opacity(0.7))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    // Indicator
                    Rectangle()
                        .fill(isSelected ?  AppColor.gold : Color.clear)
                        .frame(height: 2)
                        .cornerRadius(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Friends Tab
private struct FollowFriendsView: View {

    @ObservedObject var viewModel: FollowViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.friendsList.isEmpty {
                ProgressView()
                    .tint(.appText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.friendsList.isEmpty {
                EmptyStateView(
                    systemImage: "person.2.fill",
                    title: "no_friends_yet".localized,
                    message: "following_empty_description".localized
                )
            } else {
                List(viewModel.friendsList) { user in
                    FollowUserCell(user: user, tab: .friends, viewModel: viewModel)
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.clear)
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.load(tab: .friends)
                }
            }
        }
    }
}

// MARK: - Followers Tab
private struct FollowersView: View {
    
    @ObservedObject var viewModel: FollowViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.followersList.isEmpty {
                ProgressView()
                    .tint(.appText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.followersList.isEmpty {
                EmptyStateView(
                    systemImage: "person.crop.circle.badge.plus",
                    title: "no_followers_yet".localized,
                    message: "followers_empty_description".localized
                )
            } else {
                List(viewModel.followersList) { user in
                    FollowUserCell(user: user, tab: .followers, viewModel: viewModel)
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.clear)
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.load(tab: .followers)
                }
            }
        }
    }
}


// MARK: - Following Tab
private struct FollowingView: View {
    
    @ObservedObject var viewModel: FollowViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.followingList.isEmpty {
                ProgressView()
                    .tint(.appText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.followingList.isEmpty {
                EmptyStateView(
                    systemImage: "person.2",
                    title: "not_following_anyone".localized,
                    message: "following_empty_description".localized
                )
            } else {
                List(viewModel.followingList) { user in
                    FollowUserCell(user: user, tab: .following, viewModel: viewModel)
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.clear)
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.load(tab: .following)
                }
            }
        }
    }
}

// MARK: - Find Friends Tab
private struct LikesView: View {
    
    @ObservedObject var viewModel: FollowViewModel
    @State private var searchText = ""
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.likesList.isEmpty {
                ProgressView()
                    .tint(.appText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.likesList.isEmpty {
                EmptyStateView(
                    systemImage: "hand.thumbsup",
                    title: "not_likes_yet".localized,
                    message: "likes_empty_description".localized
                )
            } else {
                List(viewModel.likesList) { user in
                    FollowUserCell(user: user, tab: .likes, viewModel: viewModel)
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.clear)
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.load(tab: .likes)
                }
            }
        }
    }
}

private struct FollowUserCell: View {
    
    let user: FollowUserResponse
    let tab: FollowTab
    @ObservedObject var viewModel: FollowViewModel
    
    @State private var profileImage: UIImage? = nil
    @State private var showConfirmation = false
    
    private var isLoadingAction: Bool {
        viewModel.loadingUserIds.contains(user.id ?? 0)
    }
    
    private var isUnfollowed: Bool {
        viewModel.unfollowedUserIds.contains(user.id ?? 0)
    }
    
    var buttonTitle: String {
        switch tab {
        case .friends:   isUnfollowed ? "follow".localized : "following".localized
        case .followers: "remove".localized
        case .following: isUnfollowed ? "follow".localized : "unfollow".localized
        case .likes:     "unlike".localized
        }
    }

    var confirmationMessage: String {
        switch tab {
        case .friends:   isUnfollowed ? "follow_account_confirmation".localized : "unfollow_account_confirmation".localized
        case .followers: "remove_follower_confirmation".localized
        case .following: isUnfollowed ? "follow_account_confirmation".localized : "unfollow_account_confirmation".localized
        case .likes:     "unlike_post_confirmation".localized
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            
            ProfileImageView.widget(image: profileImage, size: 44, cornerRadius: 10)
                .task {
                    profileImage = await Network.shared.image(user.profilePhoto ?? "")
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.fullname ?? "no_name".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.appText)
                    .lineLimit(1)
                
                Text("@\(user.username ?? "")")
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                showConfirmation = true
            } label: {
                Group {
                    if isLoadingAction {
                        ProgressView()
                            .tint(.appText)
                            .frame(width: 18, height: 18)
                    } else {
                        Text(buttonTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .frame(minWidth: 80)
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(.thinMaterial.opacity(0.2))
                .foregroundStyle(.appText)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isLoadingAction)
            .confirmationDialog(
                confirmationMessage,
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                Button(buttonTitle, role: tab == .followers || ((tab == .following || tab == .friends) && !isUnfollowed) ? .destructive : nil) {
                    guard let userId = user.id else { return }
                    switch tab {
                    case .friends, .following:
                        if isUnfollowed {
                            viewModel.followUser(userId: userId)
                        } else {
                            viewModel.unfollowUser(userId: userId)
                        }
                    case .followers:
                        viewModel.removeFollower(userId: userId)
                    case .likes:
                        break
                    }
                }
                Button("cancel".localized, role: .cancel) {}
            }
        }
        .padding(.vertical, 4)
        .background(.clear)
    }
}

// MARK: - Empty State
private struct EmptyStateView: View {
    
    let systemImage: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(AppColor.buttonBackground)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.appText)
                
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.appText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FollowView(initialTab: .following)
    }
}
