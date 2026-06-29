//
//  LiveModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 11/06/2026.
//

import Foundation

// MARK: - Live Sub Tab

enum LiveSubTab: CaseIterable {
    case broadcasts
    case account

    var titleKey: String {
        switch self {
        case .broadcasts: "tab_live_broadcast"
        case .account:    "tab_my_account"
        }
    }
}

// MARK: - Live Category
struct LiveCategory: Identifiable, Hashable {
    let id: String
    let kind: LiveCategoryKind

    var titleKey: String { kind.titleKey }
}


enum LiveCategoryKind: String, CaseIterable {
    case mostWatched
    case followers
    case following
    case friends
    case artistsCelebrities
    case countries
    case new
    case topParents

    var titleKey: String {
        switch self {
        case .mostWatched:        "live_cat_most_watched"
        case .followers:          "live_cat_followers"
        case .following:          "live_browse_cat_following"
        case .friends:            "live_cat_friends"
        case .artistsCelebrities: "live_cat_artists_celebrities"
        case .countries:          "live_cat_countries"
        case .new:                "live_cat_new"
        case .topParents:         "live_browse_cat_parents"
        }
    }
    
    var previewImages: [String] {
          switch self {
          case .artistsCelebrities:
              return [
                  "artist_1",
                  "artist_2",
                  "artist_3",
                  "artist_4",
                  "artist_5",
                  "artist_6",
                  "artist_7",
                  "artist_8"
              ]

          default:
              return ["woman", "man"]
          }
      }
}

// MARK: - Go Live Hero
struct LiveHeroUser: Identifiable, Hashable {
    let id: String
    let username: String
    let avatarImageName: String?
    let previewImageName: String?
    let badge: String?
}

struct GoLiveHeroModel: Hashable {
    var primaryUser: LiveHeroUser
    var secondaryUser: LiveHeroUser?
}
