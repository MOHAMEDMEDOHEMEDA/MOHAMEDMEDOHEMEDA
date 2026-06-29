//
//  UpdateProfilePhotoUseCase.swift
//  Binbon
//

import UIKit

/// Uploads a new profile photo for the signed-in user.
struct UpdateProfilePhotoUseCase {
    private let repository: ProfileRepository

    init(repository: ProfileRepository) {
        self.repository = repository
    }

    func execute(image: UIImage) async throws {
        try await repository.updateProfilePhoto(image)
    }
}
