//
//  UpdateUserDetailsUseCase.swift
//  Binbon
//

import Foundation

/// Persists edits to the signed-in user's profile and returns the updated user.
struct UpdateUserDetailsUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(_ request: EditProfileRequest) async throws -> UserResponse {
        try await repository.updateUserDetails(request)
    }
}
