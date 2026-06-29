//
//  PostModel.swift
//  Binbon
//
//  The "Posts" home tab — a social text/photo/video feed. Mock-backed with
//  bundled images until a real posts API ships.
//

import Foundation

/// An image in a post — either a bundled asset (mock feed) or raw data picked
/// from the photo library (a newly composed post).
enum PostImageSource: Identifiable, Equatable {
    case asset(String)
    case data(Data)

    var id: String {
        switch self {
        case .asset(let name): "asset:\(name)"
        case .data(let data):  "data:\(data.hashValue)"
        }
    }
}

/// A single piece of post media — an image, or a video (thumbnail + playable URL).
enum PostMediaItem: Identifiable, Equatable {
    case image(PostImageSource)
    case video(thumbnail: PostImageSource, url: URL)

    var id: String {
        switch self {
        case .image(let source):  "image:\(source.id)"
        case .video(_, let url):  "video:\(url.absoluteString)"
        }
    }

    var isVideo: Bool {
        if case .video = self { return true }
        return false
    }

    /// Image to display for this item (the image itself, or the video thumbnail).
    var thumbnail: PostImageSource {
        switch self {
        case .image(let source):      source
        case .video(let thumb, _):    thumb
        }
    }

    var videoURL: URL? {
        if case .video(_, let url) = self { return url }
        return nil
    }
}

/// Media attached to a post: an ordered list of images and/or videos, shown as a
/// collage (with a +N overlay for extras).
enum PostMedia: Equatable {
    case none
    case items([PostMediaItem])
}

/// Media picked from the library in the composer — an image, or a video with its
/// generated thumbnail.
struct PickedMedia: Identifiable, Equatable {
    let id = UUID()

    enum Kind: Equatable {
        case image(Data)
        case video(url: URL, thumbnail: Data)
    }

    let kind: Kind

    var isVideo: Bool {
        if case .video = kind { return true }
        return false
    }

    /// Display image data (the image itself, or the video's thumbnail).
    var previewData: Data {
        switch kind {
        case .image(let data):        data
        case .video(_, let thumb):    thumb
        }
    }
}

struct PostModel: Identifiable, Equatable {
    let id: String
    let authorName: String
    let username: String
    /// Avatar image asset name.
    let avatar: String
    let timeAgo: String
    let caption: String
    let media: PostMedia
    var likes: Int
    let comments: Int
    let reposts: Int
    var isLiked: Bool
    var isBookmarked: Bool
}

extension Int {
    /// Compact feed count, e.g. 9600 → "9.6K", 1_200_000 → "1.2M".
    var postCountFormatted: String {
        switch self {
        case 1_000_000...:
            return trimmed(Double(self) / 1_000_000) + "M"
        case 1_000...:
            return trimmed(Double(self) / 1_000) + "K"
        default:
            return "\(self)"
        }
    }

    private func trimmed(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        return rounded == rounded.rounded()
            ? String(format: "%.0f", rounded)
            : String(format: "%.1f", rounded)
    }
}

// MARK: - Sample data

extension PostModel {
    static let samples: [PostModel] = [
        PostModel(
            id: "1",
            authorName: "Layla",
            username: "@layla.codes",
            avatar: "media-reel-1",
            timeAgo: "7m",
            caption: "Shipped the new posts feed in Compose today. Felt amazing to watch the like animation land on the first try 🙆‍♀️",
            media: .none,
            likes: 1200,
            comments: 86,
            reposts: 31,
            isLiked: true,
            isBookmarked: false
        ),
        PostModel(
            id: "2",
            authorName: "Chef Omar",
            username: "@chef.omar",
            avatar: "media-photo-1",
            timeAgo: "42m",
            caption: "Hot take: the secret to a great pasta is salting the water like the sea. No notes. 🍝",
            media: .items([.image(.asset("media-photo-2")), .image(.asset("media-reel-2")), .image(.asset("media-photo-3"))]),
            likes: 9600,
            comments: 432,
            reposts: 210,
            isLiked: false,
            isBookmarked: true
        ),
        PostModel(
            id: "3",
            authorName: "Sara Mostafa",
            username: "@sara.m",
            avatar: "media-photo-2",
            timeAgo: "2h",
            caption: "Tag someone who needs to hear this: rest is part of the work, not a reward for finishing it. ✨",
            media: .items([
                .video(
                    thumbnail: .asset("media-reel-3"),
                    url: URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!
                )
            ]),
            likes: 742,
            comments: 51,
            reposts: 19,
            isLiked: false,
            isBookmarked: false
        ),
        PostModel(
            id: "4",
            authorName: "Ahmed Gad",
            username: "@ahmed.gad",
            avatar: "media-reel-2",
            timeAgo: "5h",
            caption: "Drove three hours for this sunset and it was 100% worth it. Some views just stay with you.",
            media: .items([.image(.asset("media-reel-1")), .image(.asset("media-photo-1")), .image(.asset("media-photo-3")), .image(.asset("media-reel-3")), .image(.asset("media-photo-2"))]),
            likes: 12300,
            comments: 503,
            reposts: 88,
            isLiked: false,
            isBookmarked: false
        ),
        PostModel(
            id: "5",
            authorName: "Nour",
            username: "@nour.art",
            avatar: "media-photo-3",
            timeAgo: "1d",
            caption: "Starting a new sketch series this week. Drop a word in the replies and I'll draw it. 🎨",
            media: .none,
            likes: 4600,
            comments: 612,
            reposts: 77,
            isLiked: false,
            isBookmarked: true
        ),
        PostModel(
            id: "6",
            authorName: "Maya Carter",
            username: "@maya.carter",
            avatar: "media-reel-3",
            timeAgo: "2d",
            caption: "Two frames from the weekend hike. The mountains always reset something in me.",
            media: .items([.image(.asset("media-photo-1")), .image(.asset("media-reel-1")), .image(.asset("media-photo-2"))]),
            likes: 26500,
            comments: 1200,
            reposts: 893,
            isLiked: true,
            isBookmarked: false
        ),
    ]
}
