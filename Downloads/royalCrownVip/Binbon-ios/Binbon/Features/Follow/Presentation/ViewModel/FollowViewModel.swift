//
//  FollowViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 29/04/2026.
//

import Foundation
import Combine

@MainActor
final class FollowViewModel: ObservableObject {

    @Published var friendsList:   [FollowUserResponse] = []
    @Published var followersList: [FollowUserResponse] = []
    @Published var followingList: [FollowUserResponse] = []
    @Published var likesList:     [FollowUserResponse] = []

    @Published var isLoading = false
    @Published var error: APIError?
    @Published var loadingUserIds: Set<Int> = []
    @Published var unfollowedUserIds: Set<Int> = []

    // MARK: - Use cases
    private let getFollowersUseCase: GetFollowersUseCase
    private let getFollowingUseCase: GetFollowingUseCase
    private let followUserUseCase: FollowUserUseCase
    private let unfollowUserUseCase: UnfollowUserUseCase
    private let removeFollowerUseCase: RemoveFollowerUseCase

    init(
        getFollowersUseCase: GetFollowersUseCase,
        getFollowingUseCase: GetFollowingUseCase,
        followUserUseCase: FollowUserUseCase,
        unfollowUserUseCase: UnfollowUserUseCase,
        removeFollowerUseCase: RemoveFollowerUseCase
    ) {
        self.getFollowersUseCase = getFollowersUseCase
        self.getFollowingUseCase = getFollowingUseCase
        self.followUserUseCase = followUserUseCase
        self.unfollowUserUseCase = unfollowUserUseCase
        self.removeFollowerUseCase = removeFollowerUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            getFollowersUseCase: container.makeGetFollowersUseCase(),
            getFollowingUseCase: container.makeGetFollowingUseCase(),
            followUserUseCase: container.makeFollowUserUseCase(),
            unfollowUserUseCase: container.makeUnfollowUserUseCase(),
            removeFollowerUseCase: container.makeRemoveFollowerUseCase()
        )
    }

    func loadIfNeeded(for tab: FollowTab) {
        switch tab {
        case .friends     where friendsList.isEmpty:   load(tab: .friends)
        case .followers   where followersList.isEmpty: load(tab: .followers)
        case .following   where followingList.isEmpty: load(tab: .following)
        case .likes       where likesList.isEmpty:     load(tab: .likes)
        default: break
        }
    }

    func load(tab: FollowTab) {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            switch tab {
            case .friends:
                // No friends endpoint yet — mock-backed for the current phase.
                friendsList = Self.mockFriends

            case .followers:
                followersList.removeAll()
                do { followersList = try await getFollowersUseCase.execute() }
                catch { self.error = Network.shared.mapError(error) }

            case .following:
                followingList.removeAll()
                unfollowedUserIds.removeAll()
                do { followingList = try await getFollowingUseCase.execute() }
                catch { self.error = Network.shared.mapError(error) }

            case .likes:
                likesList.removeAll()
            }
        }
    }

    func followUser(userId: Int) {
        Task {
            loadingUserIds.insert(userId)
            defer { loadingUserIds.remove(userId) }

            do {
                try await followUserUseCase.execute(userId: userId)
                unfollowedUserIds.remove(userId)
            } catch {
                Toaster.shared.show(.error("plus.circle"), Network.shared.mapError(error).localizedMessage())
            }
        }
    }

    func unfollowUser(userId: Int) {
        Task {
            loadingUserIds.insert(userId)
            defer { loadingUserIds.remove(userId) }

            do {
                try await unfollowUserUseCase.execute(userId: userId)
                unfollowedUserIds.insert(userId)
            } catch {
                Toaster.shared.show(.error("minus.circle"), Network.shared.mapError(error).localizedMessage())
            }
        }
    }

    func removeFollower(userId: Int) {
        Task {
            loadingUserIds.insert(userId)
            defer { loadingUserIds.remove(userId) }

            do {
                try await removeFollowerUseCase.execute(userId: userId)
                followersList.removeAll { $0.id == userId }
            } catch {
                Toaster.shared.show(.error("trash.circle"), Network.shared.mapError(error).localizedMessage())
            }
        }
    }

    private static let mockFriends: [FollowUserResponse] = [
        FollowUserResponse(id: 1, fullname: "binbon",        username: "binbon",            profilePhoto: nil),
        FollowUserResponse(id: 2, fullname: "salahkhaled4272", username: "salahkhaled4272", profilePhoto: nil),
        FollowUserResponse(id: 3, fullname: "nour2023",      username: "nour2023",          profilePhoto: nil),
        FollowUserResponse(id: 4, fullname: "omar_dev",      username: "omar_dev",          profilePhoto: nil),
        FollowUserResponse(id: 5, fullname: "mariam_a",      username: "mariam_a",          profilePhoto: nil)
    ]
}
