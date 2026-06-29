//
//  ReelsRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for reels. Mock-backed during the current
//  pre-integration phase.
//

import Foundation

protocol ReelsRemoteDataSource {
    func fetchReels() async throws -> [ReelModel]
    func setReelLike(reelID: ReelModel.ID, liked: Bool) async throws
    func setReelBookmark(reelID: ReelModel.ID, bookmarked: Bool) async throws
}

// MARK: - Mock

struct MockReelsRemoteDataSource: ReelsRemoteDataSource {

    func fetchReels() async throws -> [ReelModel] {
        [ReelModel].mock
    }

    func setReelLike(reelID: ReelModel.ID, liked: Bool) async throws {}

    func setReelBookmark(reelID: ReelModel.ID, bookmarked: Bool) async throws {}
}

private extension Array where Element == ReelModel {
    static let mock: [ReelModel] = [
        ReelModel(
            id: "1",
            videoURL: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4")!,
            author: "Username 1",
            caption: "Big Buck Bunny — 10s sample",
            likes: 1234,
            date: "10-05-2026"
        ),
        ReelModel(
            id: "2",
            videoURL: URL(string: "https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4")!,
            author: "Username 2",
            caption: "Sintel — 10s sample",
            likes: 5678,
            date: "08-05-2026"
        ),
        ReelModel(
            id: "3",
            videoURL: URL(string: "https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4")!,
            author: "Username 3",
            caption: "Jellyfish — 10s sample",
            likes: 910,
            date: "01-05-2026"
        ),
        ReelModel(
            id: "4",
            videoURL: URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!,
            author: "Username 4",
            caption: "Sintel trailer",
            likes: 910,
            date: "24-04-2026"
        ),
        ReelModel(
            id: "5",
            videoURL: URL(string: "https://media.w3.org/2010/05/bunny/trailer.mp4")!,
            author: "Username 5",
            caption: "Bunny trailer",
            likes: 910,
            date: "17-04-2026"
        ),
        ReelModel(
            id: "6",
            videoURL: URL(string: "https://media.w3.org/2010/05/bunny/movie.mp4")!,
            author: "Username 6",
            caption: "Bunny full movie",
            likes: 910,
            date: "02-04-2026"
        ),
    ]
}
