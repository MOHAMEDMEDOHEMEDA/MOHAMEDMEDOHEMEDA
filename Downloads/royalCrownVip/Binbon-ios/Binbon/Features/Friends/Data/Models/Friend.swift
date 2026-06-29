//
//  Friend.swift
//  Binbon
//
//  Created by Mrwan Hany on 10/06/2026.
//
//  A friend who can be selected as an audience for a post. Placeholder sample
//  data until a real friends API is wired in.
//

import Foundation

struct Friend: Identifiable, Equatable {
    let id = UUID()
    let name: String
    /// Remote avatar URL when available; nil falls back to an initial badge.
    let avatarURL: String?

    init(name: String, avatarURL: String? = nil) {
        self.name = name
        self.avatarURL = avatarURL
    }

    static let samples: [Friend] = {
        let names = ["Amiraali", "Soltan Khames", "Hamza Morad", "Eman Ezat"]
        // 32 entries — mirrors the design's "32 Friends" list.
        return (0..<32).map { Friend(name: names[$0 % names.count]) }
    }()
}
