//
//  ActivityRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for the activity feed. Mock-backed during the
//  current pre-integration phase; returns domain entities.
//

import Foundation

protocol ActivityRemoteDataSource {
    func fetchActivity(page: Int, perPage: Int) async throws -> ActivityFeedResponse
    func followUser(userId: Int) async throws
    func unFollowUser(userId: Int) async throws
    func markRead(id: Int) async throws
}

// MARK: - Mock

struct MockActivityRemoteDataSource: ActivityRemoteDataSource {

    func fetchActivity(page: Int, perPage: Int) async throws -> ActivityFeedResponse {
        try Self.decodeFeed()
    }

    func followUser(userId: Int) async throws {}
    func unFollowUser(userId: Int) async throws {}
    func markRead(id: Int) async throws {}

    private static func decodeFeed() throws -> ActivityFeedResponse {
        guard let data = Self.json.data(using: .utf8) else {
            throw APIError(type: .parsing, message: "Invalid mock JSON")
        }
        do {
            let envelope = try JSONDecoder().decode(BaseResponse<ActivityFeedResponse>.self, from: data)
            guard let feed = envelope.data else {
                throw APIError(type: .parsing, message: "Empty mock activity feed")
            }
            return feed
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError(type: .parsing, message: "\(error)")
        }
    }

    private static let json = #"""
    {"status":true,"message":"OK","data":{"items":[
      {"id":1,"kind":"follow","actorName":"Sara","actorUsername":"sara.m","actorImageURL":null,"message":"started following you","timeAgo":"1h","timestamp":"2026-06-17T10:00:00Z","isFollowing":false,"thumbnailURL":null,"userId":501},
      {"id":2,"kind":"like","actorName":"Omar","actorUsername":"chef.omar","actorImageURL":null,"message":"liked your video","timeAgo":"3h","timestamp":"2026-06-17T08:00:00Z","isFollowing":true,"thumbnailURL":null,"userId":502},
      {"id":3,"kind":"mention","actorName":"Nour","actorUsername":"nour.art","actorImageURL":null,"message":"mentioned you in a comment","timeAgo":"1d","timestamp":"2026-06-16T10:00:00Z","isFollowing":false,"thumbnailURL":null,"userId":503},
      {"id":4,"kind":"follow","actorName":"Yousef","actorUsername":"yousef","actorImageURL":null,"message":"started following you","timeAgo":"2d","timestamp":"2026-06-15T10:00:00Z","isFollowing":false,"thumbnailURL":null,"userId":504}
    ]}}
    """#
}
