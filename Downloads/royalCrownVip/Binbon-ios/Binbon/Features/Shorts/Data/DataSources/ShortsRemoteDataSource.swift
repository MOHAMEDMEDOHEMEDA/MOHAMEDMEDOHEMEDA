//
//  ShortsRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for shorts. Mock-backed during the current
//  pre-integration phase.
//

import Foundation

protocol ShortsRemoteDataSource {
    func fetchShorts() async throws -> [ShortModel]
    func setShortLike(shortID: ShortModel.ID, liked: Bool) async throws
}

// MARK: - Mock

struct MockShortsRemoteDataSource: ShortsRemoteDataSource {

    func fetchShorts() async throws -> [ShortModel] {
        [ShortModel].mock
    }

    func setShortLike(shortID: ShortModel.ID, liked: Bool) async throws {}
}

private extension Array where Element == ShortModel {
    static let mock: [ShortModel] = [
        ShortModel(
            id: "1",
            videoURL: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4")!,
            author: "nour.art",
            authorAvatarURL: "https://i.pravatar.cc/150?img=47",
            caption: "Mixing my own colors for the first time and honestly obsessed with how this turned out 🎨",
            tags: "@layla.codes #art #binbon #satisfying",
            soundTitle: "Aurora",
            soundArtist: "Nour Hassan",
            soundAvatarURL: "https://i.pravatar.cc/150?img=32",
            viewsText: "1.4M",
            likesText: "182K",
            commentsText: "2,910",
            sharesText: "6,402"
        ),
        ShortModel(
            id: "2",
            videoURL: URL(string: "https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4")!,
            author: "khaled.moves",
            authorAvatarURL: "https://i.pravatar.cc/150?img=12",
            caption: "Late night studio session, the beat just hit different tonight 🎧",
            tags: "@studio.beats #music #binbon #vibes",
            soundTitle: "Midnight",
            soundArtist: "Khaled M.",
            soundAvatarURL: "https://i.pravatar.cc/150?img=15",
            viewsText: "920K",
            likesText: "94K",
            commentsText: "1,204",
            sharesText: "3,180"
        ),
        ShortModel(
            id: "3",
            videoURL: URL(string: "https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4")!,
            author: "sara.eats",
            authorAvatarURL: "https://i.pravatar.cc/150?img=45",
            caption: "30-second recipe you'll actually make this week 🍝",
            tags: "@quick.kitchen #food #binbon #recipe",
            soundTitle: "Kitchen Pop",
            soundArtist: "Sara A.",
            soundAvatarURL: "https://i.pravatar.cc/150?img=49",
            viewsText: "2.1M",
            likesText: "311K",
            commentsText: "5,640",
            sharesText: "12.3K"
        ),
    ]
}
