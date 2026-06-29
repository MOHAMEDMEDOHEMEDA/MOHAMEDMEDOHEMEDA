//
//  RichCommentsViewModel.swift
//  Binbon
//
//  Drives the rich comments sheet: holds the comments for each tab, the selected
//  tab, the draft text, and like toggling. Mock-backed for now.
//

import SwiftUI
import Combine

@MainActor
final class RichCommentsViewModel: ObservableObject {

    @Published var selectedTab: CommentTab = .comments
    @Published var draft: String = ""
    @Published private(set) var comments: [CommentTab: [RichComment]] = [:]

    var current: [RichComment] {
        comments[selectedTab] ?? []
    }

    func load() {
        guard comments.isEmpty else { return }
        comments = [
            .comments: Self.textComments,
            .gif: Self.gifComments,
            .sticker: Self.stickerComments,
            .voice: Self.voiceComments
        ]
    }

    func toggleLike(_ id: RichComment.ID) {
        for tab in comments.keys {
            guard var list = comments[tab] else { continue }
            if mutateLike(in: &list, id: id) {
                comments[tab] = list
                return
            }
        }
    }

    /// Recursively toggles like on a comment or one of its replies.
    private func mutateLike(in list: inout [RichComment], id: RichComment.ID) -> Bool {
        for index in list.indices {
            if list[index].id == id {
                list[index].isLiked.toggle()
                list[index].likes += list[index].isLiked ? 1 : -1
                return true
            }
            if mutateLike(in: &list[index].replies, id: id) { return true }
        }
        return false
    }

    func sendDraft() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let comment = RichComment(
            username: "you".localized,
            time: "now",
            avatar: "media-reel-1",
            kind: .text,
            text: text,
            likes: 0,
            isLiked: false
        )
        comments[.comments, default: []].insert(comment, at: 0)
        draft = ""
    }

    // MARK: - Mock data

    private static let textComments: [RichComment] = [
        RichComment(username: "@noor90", time: "2h", avatar: "media-photo-2", kind: .text, text: "Absolutely magic!", likes: 42, isLiked: false),
        RichComment(username: "@layla_h", time: "5h", avatar: "media-reel-1", kind: .text, text: "Love this vibe!", likes: 128, isLiked: true),
        RichComment(
            username: "@sara_23", time: "1d", avatar: "media-photo-1", kind: .text, text: "So inspiring tbh", likes: 89, isLiked: false,
            replies: [
                RichComment(username: "@sara_23", time: "1d", avatar: "media-photo-1", kind: .text, text: "So inspiring tbh", mention: "@ahmed", likes: 22, isLiked: false)
            ]
        ),
        RichComment(username: "@dalia_a", time: "6h", avatar: "media-photo-3", kind: .text, text: "You're on fire!", likes: 15, isLiked: false),
        RichComment(username: "@ahmed", time: "18h", avatar: "media-reel-2", kind: .text, text: "Truly an artist", likes: 22, isLiked: false)
    ]

    private static let gifComments: [RichComment] = [
        RichComment(username: "@ahmed", time: "18h", avatar: "media-reel-2", kind: .gif(asset: "media-photo-1", caption: "Hii Bye!"), likes: 22, isLiked: true),
        RichComment(username: "@layla_h", time: "5h", avatar: "media-reel-1", kind: .gif(asset: "media-photo-3", caption: "Pok Ro"), likes: 22, isLiked: false),
        RichComment(username: "@ahmed", time: "18h", avatar: "media-reel-2", kind: .gif(asset: "media-photo-2", caption: "Nice one"), likes: 8, isLiked: false)
    ]

    private static let stickerComments: [RichComment] = [
        RichComment(username: "@ahmed", time: "18h", avatar: "media-reel-2", kind: .sticker(asset: "media-photo-1"), likes: 22, isLiked: false),
        RichComment(username: "@dalia_a", time: "6h", avatar: "media-photo-3", kind: .sticker(asset: "media-photo-2"), likes: 14, isLiked: true),
        RichComment(username: "@karim_22", time: "12h", avatar: "media-reel-3", kind: .sticker(asset: "media-photo-3"), likes: 31, isLiked: false)
    ]

    private static let voiceComments: [RichComment] = [
        RichComment(username: "@ahmed", time: "18h", avatar: "media-reel-2", kind: .voice(duration: "0:20"), likes: 22, isLiked: false),
        RichComment(username: "@layla_h", time: "5h", avatar: "media-reel-1", kind: .voice(duration: "0:12"), likes: 18, isLiked: true),
        RichComment(username: "@karim_22", time: "12h", avatar: "media-reel-3", kind: .voice(duration: "0:34"), likes: 9, isLiked: false),
        RichComment(username: "@sara_23", time: "1d", avatar: "media-photo-1", kind: .voice(duration: "0:08"), likes: 41, isLiked: false),
        RichComment(username: "@youssef", time: "3d", avatar: "media-reel-2", kind: .voice(duration: "0:45"), likes: 27, isLiked: false)
    ]
}
