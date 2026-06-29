//
//  BlockedUsersViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 07/06/2026.
//

import SwiftUI
import Combine

@MainActor
class BlockedUsersViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var blockedUsers: [BlockedUser] = []
    @Published var blockUsername: String = ""
    @Published var isLoadingBlocked = false
    @Published var blockError: APIError?
    
    // MARK: - Pagination
    private let perPage: Int = 20
    private var nextCursor: String? = nil
    private var hasMore: Bool = true
    
    // MARK: - Private
    private let fetchBlockedUsersUseCase: FetchBlockedUsersUseCase
    private let blockUserUseCase: BlockUserUseCase
    private let unblockUserUseCase: UnblockUserUseCase

    init(
        fetchBlockedUsersUseCase: FetchBlockedUsersUseCase,
        blockUserUseCase: BlockUserUseCase,
        unblockUserUseCase: UnblockUserUseCase
    ) {
        self.fetchBlockedUsersUseCase = fetchBlockedUsersUseCase
        self.blockUserUseCase = blockUserUseCase
        self.unblockUserUseCase = unblockUserUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchBlockedUsersUseCase: container.makeFetchBlockedUsersUseCase(),
            blockUserUseCase: container.makeBlockUserUseCase(),
            unblockUserUseCase: container.makeUnblockUserUseCase()
        )
    }

    // MARK: - Get
    func fetchBlockedUsers(reset: Bool = false) {
        guard !isLoadingBlocked else { return }
        guard hasMore || reset else { return }

        isLoadingBlocked = true

        if reset {
            nextCursor = nil
            hasMore = true
            blockedUsers = []
        }

        Task {
            defer { isLoadingBlocked = false }

            do {
                let response = try await fetchBlockedUsersUseCase.execute(
                    BlockedUsersRequest(cursor: nextCursor, perPage: perPage)
                )
                blockedUsers += response.data
                nextCursor = response.meta.nextCursor
                hasMore = response.meta.hasMore
            } catch {
                blockError = asAPIError(error)
            }
        }
    }

    // MARK: - Add
    func blockUser() {
        let username = blockUsername.trimmingCharacters(in: .whitespaces)
        guard !username.isEmpty else { return }

        Task {
            do {
                try await blockUserUseCase.execute(username: username)
                blockUsername = ""
                fetchBlockedUsers(reset: true)
            } catch {
                blockError = asAPIError(error)
            }
        }
    }

    // MARK: - Delete
    func unblockUser(_ user: BlockedUser) {
        Task {
            do {
                try await unblockUserUseCase.execute(id: user.id)
                blockedUsers.removeAll { $0.id == user.id }
            } catch {
                blockError = asAPIError(error)
            }
        }
    }
    
    // MARK: - Pagination trigger
    func loadMoreIfNeeded(currentUser user: BlockedUser) {
        guard let last = blockedUsers.last, last.id == user.id else { return }
        fetchBlockedUsers()
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
