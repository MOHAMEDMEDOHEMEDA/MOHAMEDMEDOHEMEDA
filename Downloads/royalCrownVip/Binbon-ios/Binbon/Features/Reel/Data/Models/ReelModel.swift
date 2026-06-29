//
//  ReelModel.swift
//  Binbon
//
//  Created by Salah Khaled on 25/05/2026.
//

import Foundation

// MARK: - Domain model
struct ReelModel: Identifiable, Equatable {
    let id: String
    let videoURL: URL
    let author: String
    let caption: String
    var likes: Int
    /// Human-readable publish date shown beside the author (e.g. "2d ago").
    var date: String = ""
}

// MARK: - Request
struct ReelsRequest: Encodable {
    let cursor: String?
    let pageSize: Int

    enum CodingKeys: String, CodingKey {
        case cursor
        case pageSize = "page_size"
    }
}

// MARK: - Response
struct ReelsResponse: Decodable {
    let items: [Item]
    let nextCursor: String?

    struct Item: Decodable {
        let id: String
        let videoURL: URL
        let author: String
        let caption: String
        let likes: Int

        enum CodingKeys: String, CodingKey {
            case id
            case videoURL = "video_url"
            case author
            case caption
            case likes
        }
    }

    enum CodingKeys: String, CodingKey {
        case items
        case nextCursor = "next_cursor"
    }
    
    func asModels() -> [ReelModel] {
        items.map {
            ReelModel(
                id: $0.id,
                videoURL: $0.videoURL,
                author: $0.author,
                caption: $0.caption,
                likes: $0.likes
            )
        }
    }
}
