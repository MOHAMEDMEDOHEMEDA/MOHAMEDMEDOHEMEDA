//
//  PhotoPostModel.swift
//  Binbon
//
//  Created by Mrwan hany on 15/06/2026.
//

import Foundation

// MARK: - Domain model
struct PhotoPostModel: Identifiable, Equatable, Hashable {
    let id: String
    let author: String
    let avatarURL: String
    let caption: String
    /// One post can carry several photos shown as a swipeable carousel.
    let photoURLs: [String]
    var likeCount: Int
    var commentCount: Int
    /// Avatars of people who reacted, stacked over the bottom-right of the photo.
    let repostAvatars: [String]
    var isLiked: Bool
    var isBookmarked: Bool
}

extension PhotoPostModel {
    static let mockFeed: [PhotoPostModel] = [
        PhotoPostModel(
            id: "1",
            author: "Dalia Ahmed",
            avatarURL: "https://i.pravatar.cc/150?img=5",
            caption: "Every day is a new chance to grow, to learn something new, and to become a little better than you were yesterday. Chasing the light and collecting moments wherever this journey takes me.",
            photoURLs: [
                "https://picsum.photos/id/64/600/600",
                "https://picsum.photos/id/65/600/600",
                "https://picsum.photos/id/91/600/600",
                "https://picsum.photos/id/177/600/600"
            ],
            likeCount: 3100,
            commentCount: 200,
            repostAvatars: [
                "https://i.pravatar.cc/150?img=12",
                "https://i.pravatar.cc/150?img=32"
         
            ],
            isLiked: true,
            isBookmarked: true
        ),
        PhotoPostModel(
            id: "2",
            author: "Samy Amr",
            avatarURL: "https://i.pravatar.cc/150?img=15",
            caption: "Golden hour never disappoints",
            // Single-image post — the page control should hide for this one.
            photoURLs: [
                "https://picsum.photos/id/29/600/600"
            ],
            likeCount: 842,
            commentCount: 57,
            repostAvatars: [
                "https://i.pravatar.cc/150?img=22",
                "https://i.pravatar.cc/150?img=45"
            ],
            isLiked: false,
            isBookmarked: false
        ),
        PhotoPostModel(
            id: "3",
            author: "Lina Hassan",
            avatarURL: "https://i.pravatar.cc/150?img=9",
            caption: "Weekend escapes and quiet streets, slow mornings with good coffee, and the kind of golden afternoons you wish would never end. Saving these little memories before they fade away.",
            photoURLs: [
                "https://picsum.photos/id/82/600/600",
                "https://picsum.photos/id/100/600/600",
                "https://picsum.photos/id/106/600/600",
                "https://picsum.photos/id/119/600/600"
            ],
            likeCount: 1450,
            commentCount: 113,
            repostAvatars: [
                "https://i.pravatar.cc/150?img=51",
                "https://i.pravatar.cc/150?img=60"
            ],
            isLiked: false,
            isBookmarked: true
        )
    ]
}
