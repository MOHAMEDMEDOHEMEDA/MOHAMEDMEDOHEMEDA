//
//  CommentsRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for comments. Mock-backed during the current
//  pre-integration phase.
//

import Foundation

protocol CommentsRemoteDataSource {
    func fetch(targetID: String) async throws -> [CommentModel]
}

// MARK: - Mock

struct MockCommentsRemoteDataSource: CommentsRemoteDataSource {
    func fetch(targetID: String) async throws -> [CommentModel] {
        CommentModel.mockFeed
    }
}

private extension CommentModel {
    static let mockFeed: [CommentModel] = [
        CommentModel(
            id: "1",
            author: "Ali Salah",
            avatarURL: "https://i.pravatar.cc/150?img=12",
            text: "Lorem Ipsum is simply dummy",
            reactions: ["😍"],
            likeCount: 20,
            isLiked: false,
            timestamp: "4day"
        ),
        CommentModel(
            id: "2",
            author: "Mona Hasan",
            avatarURL: "https://i.pravatar.cc/150?img=32",
            text: "Lorem Ipsum is simply",
            reactions: ["😍", "😍"],
            likeCount: 60,
            isLiked: true,
            timestamp: "4day"
        ),
        CommentModel(
            id: "3",
            author: "Doha sabdy",
            avatarURL: "https://i.pravatar.cc/150?img=45",
            text: "Lorem Ipsum is simply dummy",
            reactions: ["😍", "😂", "😂", "😂", "😂"],
            likeCount: 60,
            isLiked: true,
            timestamp: "4day"
        ),
        CommentModel(
            id: "4",
            author: "Ali Salah",
            avatarURL: "https://i.pravatar.cc/150?img=5",
            text: "Lorem Ipsum is simply dummy",
            reactions: ["😍"],
            likeCount: 20,
            isLiked: false,
            timestamp: "4day"
        ),
        CommentModel(
            id: "5",
            author: "Mona Hasan",
            avatarURL: "https://i.pravatar.cc/150?img=9",
            text: "Lorem Ipsum is simply",
            reactions: ["😍", "😍"],
            likeCount: 60,
            isLiked: true,
            timestamp: "4day"
        ),
        CommentModel(
            id: "6",
            author: "Doha sabdy",
            avatarURL: "https://i.pravatar.cc/150?img=60",
            text: "Lorem Ipsum is simply dummy",
            reactions: ["😍", "😂", "😂", "😂", "😂"],
            likeCount: 60,
            isLiked: true,
            timestamp: "4day"
        )
    ]
}
