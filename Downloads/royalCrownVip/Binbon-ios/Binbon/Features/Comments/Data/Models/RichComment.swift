//
//  RichComment.swift
//  Binbon
//
//  Comments for the posts / reels comment sheet. Supports text, GIF, sticker and
//  voice comments plus nested replies. Mock-backed with bundled images.
//

import Foundation

enum CommentTab: String, CaseIterable, Identifiable {
    case gif
    case sticker
    case voice
    case comments

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gif:      "comments_tab_gif".localized
        case .sticker:  "comments_tab_sticker".localized
        case .voice:    "comments_tab_voice".localized
        case .comments: "comments_tab_comments".localized
        }
    }
}

enum CommentKind: Equatable {
    case text
    /// A GIF/image with an optional caption bubble.
    case gif(asset: String, caption: String)
    case sticker(asset: String)
    case voice(duration: String)
}

struct RichComment: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let time: String
    let avatar: String
    let kind: CommentKind
    /// Body text for `.text` comments.
    var text: String = ""
    /// Optional @mention shown before the text (replies).
    var mention: String = ""
    var likes: Int
    var isLiked: Bool
    var replies: [RichComment] = []
}
