//
//  FollowTab.swift
//  Binbon
//
//  Created by Salah Khaled on 29/04/2026.
//

import Foundation

enum FollowTab: CaseIterable {

    case friends
    case following
    case followers
    case likes

    var title: String {
        switch self {
        case .friends:   "friends".localized
        case .following: "following".localized
        case .followers: "followers".localized
        case .likes:     "likes".localized
        }
    }
}
