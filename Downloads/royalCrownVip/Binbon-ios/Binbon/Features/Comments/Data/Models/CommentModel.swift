//
//  CommentModel.swift
//  Binbon
//
//  Created by Mrwan hany on 15/06/2026.
//

import Foundation

struct CommentModel: Identifiable, Equatable {
    let id: String
    let author: String
    let avatarURL: String
    let text: String
    /// Emoji reactions shown inline right after the comment text; they wrap
    /// onto the next line when there are several.
    let reactions: [String]
    var likeCount: Int
    var isLiked: Bool
    /// Relative time label as supplied by the backend, e.g. "4day".
    let timestamp: String
}
