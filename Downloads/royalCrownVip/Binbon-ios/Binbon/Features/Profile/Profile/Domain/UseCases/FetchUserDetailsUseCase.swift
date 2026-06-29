//
//  FetchUserDetailsUseCase.swift
//  Binbon
//

import Foundation

/// Loads the signed-in user's profile.
struct FetchUserDetailsUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute() async throws -> UserResponse {
        try await repository.fetchUserDetails()
    }
}
