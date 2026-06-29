//
//  VideosRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the videos feed. Mock-backed during the
//  current pre-integration phase.
//

import Foundation

protocol VideosRemoteDataSource {
    func fetchVideosFeed() async throws -> [VideoModel]
}

// MARK: - Mock

struct MockVideosRemoteDataSource: VideosRemoteDataSource {

    func fetchVideosFeed() async throws -> [VideoModel] {
        [VideoModel].mock
    }
}

private extension Array where Element == VideoModel {
    static let mock: [VideoModel] = [
        .init(
            id: "1",
            thumbnailURL: "https://picsum.photos/seed/binbon1/800/600",
            videoURL: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4"),
            duration: "1:40:39",
            title: "Lorem Ipsum is simply is lo @dummy text",
            hashtags: "#Lorem #Lorem #Lorem",
            views: "1k views",
            age: "1 hour ago",
            authorName: "MONA 🌹 FLOWR",
            authorAvatarURL: "https://picsum.photos/seed/avatar1/100"
        ),
        .init(
            id: "2",
            thumbnailURL: "https://picsum.photos/seed/binbon2/800/600",
            videoURL: URL(string: "https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4"),
            duration: "1:40:39",
            title: "Lorem Ipsum is simply is lo @dummy text",
            hashtags: "#Lorem #Lorem #Lorem",
            views: "12K views",
            age: "3 hour ago",
            authorName: "Fathy Flames",
            authorAvatarURL: "https://picsum.photos/seed/avatar2/100"
        ),
        .init(
            id: "3",
            thumbnailURL: "https://picsum.photos/seed/binbon3/800/600",
            videoURL: URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4"),
            duration: "12:10",
            title: "New travel story with sunset vibes",
            hashtags: "#Travel #Sunset #Vibes",
            views: "22K views",
            age: "5 hour ago",
            authorName: "Sara Bloom",
            authorAvatarURL: "https://picsum.photos/seed/avatar3/100"
        )
    ]
}
