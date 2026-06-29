//
//  ProfileRepositoryImpl.swift
//  Binbon
//
//  Created by Mrwan hany on 15/06/2026.
//

import UIKit

final class ProfileRepositoryImpl: ProfileRepository {

    private let repo = ProfileRepo()

    func fetchUserDetails() async throws -> UserResponse {
        let response = try await repo.fetchUserDetails().get()
        let user = try unwrap(response)
        Storage.shared.user = user
        return user
    }

    func updateUserDetails(_ request: EditProfileRequest) async throws -> UserResponse {
        let response = try await repo.updateUserDetails(request: request).get()
        let user = try unwrap(response)
        Storage.shared.user = user
        return user
    }

    func updateProfilePhoto(_ image: UIImage) async throws {
        try ensureSuccess(await repo.updateProfilePhoto(image: image).get())
    }

    func recommendedUsers(limit: Int) async throws -> [RecommendUserResponse] {
        try unwrap(await repo.recommendedUsers(limit: limit).get())
    }

    func followers() async throws -> [FollowUserResponse] {
        try unwrap(await repo.getFollowers().get())
    }

    func following() async throws -> [FollowUserResponse] {
        try unwrap(await repo.getFollowing().get())
    }

    func followUser(id: Int) async throws {
        try ensureSuccess(await repo.followUser(userId: id).get())
    }

    func unfollowUser(id: Int) async throws {
        try ensureSuccess(await repo.unfollowUser(userId: id).get())
    }

    func removeFollower(id: Int) async throws {
        try ensureSuccess(await repo.removeFollower(userId: id).get())
    }

    func shareLink() async throws -> ShareLinkResponse {
        try unwrap(await repo.shareLink().get())
    }
}

// MARK: - Envelope unwrapping
private extension ProfileRepositoryImpl {

    /// Returns the payload of a successful response, or throws with the server message.
    func unwrap<T>(_ response: BaseResponse<T>) throws -> T {
        guard response.status == true, let data = response.data else {
            throw APIError(type: .unknown, message: response.message)
        }
        return data
    }

    /// Validates a dataless response (action endpoints returning `EmptyResponse`).
    func ensureSuccess<T>(_ response: BaseResponse<T>) throws {
        guard response.status == true else {
            throw APIError(type: .unknown, message: response.message)
        }
    }
}
