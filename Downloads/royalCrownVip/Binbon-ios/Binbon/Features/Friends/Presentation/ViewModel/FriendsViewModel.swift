//
//  FriendsViewModel.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//

import Combine
import Foundation

@MainActor
final class FriendsViewModel: ObservableObject {

    @Published private(set) var friends: [Friend] = []

    /// Title like "32 Friends".
    var title: String { "\(friends.count) \("friends".localized)" }

    func load() {
        // Swap in a real friends API later.
        friends = Friend.samples
    }
}
