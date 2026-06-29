//
//  SocialLoginUseCase.swift
//  Binbon
//
//  Domain layer — authenticates a user through a third-party social provider.
//

import Foundation

struct SocialLoginUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    func execute(provider: SocialProvider, token: String) async throws -> UserResponse {
        try await repository.socialLogin(provider: provider, token: token)
    }
}
