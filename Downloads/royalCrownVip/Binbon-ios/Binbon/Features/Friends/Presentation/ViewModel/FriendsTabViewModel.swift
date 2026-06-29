//
//  FriendsTabViewModel.swift
//  Binbon
//
//  Drives the Friends tab list and the per-row action menu (Block/Report/Mute).
//

import Combine
import Foundation

@MainActor
final class FriendsTabViewModel: ObservableObject {

    @Published private(set) var friends: [FriendItem] = []
    /// Row whose action menu is currently open; nil when no menu is showing.
    @Published var openMenuFriendID: FriendItem.ID?

    private let loadFriendsUseCase: LoadFriendsUseCase

    init(loadFriendsUseCase: LoadFriendsUseCase) {
        self.loadFriendsUseCase = loadFriendsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(loadFriendsUseCase: container.makeLoadFriendsUseCase())
    }

    func load() {
        Task {
            do {
                friends = try await loadFriendsUseCase.execute()
            } catch {
                friends = []
            }
        }
    }

    // MARK: - Action menu

    func toggleMenu(for id: FriendItem.ID) {
        openMenuFriendID = (openMenuFriendID == id) ? nil : id
    }

    func closeMenu() {
        openMenuFriendID = nil
    }

    // MARK: - Row actions
    // Mock-backed for now; wire to the repo once the friends API ships.

    func toggleFollow(_ id: FriendItem.ID) {
        guard let index = friends.firstIndex(where: { $0.id == id }) else { return }
        friends[index].isFollowing.toggle()
    }

    func block(_ id: FriendItem.ID) {
        friends.removeAll { $0.id == id }
        closeMenu()
    }

    func report(_ id: FriendItem.ID) -> FriendItem? {
        guard let friend = friends.first(where: { $0.id == id }) else { return nil }
        closeMenu()
        return friend
    }

    func mute(_ id: FriendItem.ID) {
        closeMenu()
        Toaster.shared.show(.success(), "friend_muted".localized, 3)
    }
}
