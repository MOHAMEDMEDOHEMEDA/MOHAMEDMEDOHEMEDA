//
//  ProfileRepository.swift
//  Binbon
//
//  Domain layer — the abstraction the use cases depend on. The concrete
//  implementation lives in the Data layer (`ProfileRepositoryImpl`).
//

import UIKit

/// Profile domain boundary. Methods return domain entities (the app's models are
/// reused as entities) and throw `APIError` on failure — the transport envelope
/// (`BaseResponse`) never leaks past this boundary.
protocol ProfileRepository {
    func fetchUserDetails() async throws -> UserResponse
    func updateUserDetails(_ request: EditProfileRequest) async throws -> UserResponse
    func updateProfilePhoto(_ image: UIImage) async throws
    func recommendedUsers(limit: Int) async throws -> [RecommendUserResponse]
    func followers() async throws -> [FollowUserResponse]
    func following() async throws -> [FollowUserResponse]
    func followUser(id: Int) async throws
    func unfollowUser(id: Int) async throws
    func removeFollower(id: Int) async throws
    func shareLink() async throws -> ShareLinkResponse
}
