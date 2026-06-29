//
//  FindFriendsView.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import SwiftUI

struct FindFriendsView: View {
    
    @StateObject var viewModel = FindFriendsViewModel()
    @State private var searchText = ""
    
    var filteredUsers: [RecommendUserResponse] {
        guard !searchText.isEmpty else { return viewModel.userList }
        return viewModel.userList.filter {
            ($0.fullname ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.username ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.userList.isEmpty {
                ProgressView()
                    .tint(.appText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.appText)
                            TextField("search".localized, text: $searchText)
                                .font(.body)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .foregroundStyle(.appText)
                        }
                        .padding(12)
                        .background(.thinMaterial.opacity(0.2), in: Capsule())
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(Color.clear)
                    }
                    
                    if filteredUsers.isEmpty {
                        Text("no_search_results".localizedFormat(searchText))
                            .font(.footnote)
                            .foregroundStyle(.appText.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowSeparatorTint(Color.clear)
                    } else {
                        Section("suggested_for_you".localized) {
                            ForEach(filteredUsers) { user in
                                UserCell(user: user, viewModel: viewModel)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparatorTint(Color.clear)
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .listStyle(.plain)
                .refreshable {
                    viewModel.loadFriends()
                }
            }
        }
        .adaptiveContentWidth()
        .onTapDismissKeyboard()
        .appBackground()
        .appNavigation(title: "find_friends".localized)
        .errorAlert(error: $viewModel.error)
        .onAppear { viewModel.loadFriends() }
    }
}

private struct UserCell: View {
    
    let user: RecommendUserResponse
    @ObservedObject var viewModel: FindFriendsViewModel
    
    @State private var profileImage: UIImage? = nil
    @State private var showConfirmation = false
    
    private var isFollowing: Bool {
        viewModel.followingUserIds.contains(user.id ?? 0)
    }
    
    private var isLoadingAction: Bool {
        viewModel.loadingUserIds.contains(user.id ?? 0)
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
                
                if let bio = user.bio {
                    Text(bio)
                        .font(.caption)
                        .foregroundStyle(.appText.opacity(0.7))
                        .lineLimit(1)
                }
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
                        Text(isFollowing ? "unfollow".localized : "follow".localized)
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
                isFollowing ? "unfollow_confirmation".localized : "follow_confirmation".localized,
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                Button(isFollowing ? "unfollow".localized : "follow".localized, role: isFollowing ? .destructive : nil) {
                    guard let id = user.id else { return }
                    if isFollowing {
                        viewModel.unfollow(userId: id)
                    } else {
                        viewModel.follow(userId: id)
                    }
                }
                Button("cancel".localized, role: .cancel) {}
            }
        }
        .padding(.vertical, 4)
        .background(.clear)
    }
}

#Preview {
    FindFriendsView()
}
