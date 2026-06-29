//
//  FindFriendsViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import Foundation
import Combine

@MainActor
final class FindFriendsViewModel: ObservableObject {

    @Published var userList: [RecommendUserResponse] = []
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var limit: Int = 10
    @Published var followingUserIds: Set<Int> = []
    @Published var loadingUserIds: Set<Int> = []

    // MARK: - Use cases
    private let recommendedUsersUseCase: RecommendedUsersUseCase
    private let followUserUseCase: FollowUserUseCase
    private let unfollowUserUseCase: UnfollowUserUseCase

    init(
        recommendedUsersUseCase: RecommendedUsersUseCase,
        followUserUseCase: FollowUserUseCase,
        unfollowUserUseCase: UnfollowUserUseCase
    ) {
        self.recommendedUsersUseCase = recommendedUsersUseCase
        self.followUserUseCase = followUserUseCase
        self.unfollowUserUseCase = unfollowUserUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            recommendedUsersUseCase: container.makeRecommendedUsersUseCase(),
            followUserUseCase: container.makeFollowUserUseCase(),
            unfollowUserUseCase: container.makeUnfollowUserUseCase()
        )
    }

    func loadFriends() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            userList.removeAll()
            do { userList = try await recommendedUsersUseCase.execute(limit: limit) }
            catch { self.error = Network.shared.mapError(error) }
        }
    }

    func follow(userId: Int) {
        Task {
            loadingUserIds.insert(userId)
            defer { loadingUserIds.remove(userId) }

            do {
                try await followUserUseCase.execute(userId: userId)
                followingUserIds.insert(userId)
            } catch {
                Toaster.shared.show(.error("plus.circle"), Network.shared.mapError(error).localizedMessage())
            }
        }
    }

    func unfollow(userId: Int) {
        Task {
            loadingUserIds.insert(userId)
            defer { loadingUserIds.remove(userId) }

            do {
                try await unfollowUserUseCase.execute(userId: userId)
                followingUserIds.remove(userId)
            } catch {
                Toaster.shared.show(.error("minus.circle"), Network.shared.mapError(error).localizedMessage())
            }
        }
    }
}
