//
//  NotificationsViewModel.swift
//  Binbon
//
//  Created by Husayn on 09/06/2026.
//

import UIKit
import Combine

@MainActor
final class NotificationsViewModel: ObservableObject {

    // MARK: - Properties
    @Published var newFollowers: [NewFollower] = []
    @Published var error: APIError?
    @Published var isLoading: Bool = false

    // MARK: - Lifecycle
    func onAppear() {
        guard newFollowers.isEmpty else { return }
        fetch()
    }

    func fetch() {
        // TODO: Replace with API call
        newFollowers = [
            NewFollower(id: 1, name: "Hamza Syria",  imageURL: nil, timeAgo: "17_hours_ago".localized, isFollowing: false),
            NewFollower(id: 2, name: "Sara Bnt Syria", imageURL: nil, timeAgo: "1_day_ago".localized,   isFollowing: false),
            NewFollower(id: 3, name: "Salah Syria",  imageURL: nil, timeAgo: "6_days_ago".localized,   isFollowing: false),
        ]
    }

    // MARK: - Actions
    func followBack(_ follower: NewFollower) {
        guard let index = newFollowers.firstIndex(where: { $0.id == follower.id }) else { return }
        newFollowers[index].isFollowing.toggle()
        // TODO: Replace with API call to follow/unfollow the user.
    }
}
