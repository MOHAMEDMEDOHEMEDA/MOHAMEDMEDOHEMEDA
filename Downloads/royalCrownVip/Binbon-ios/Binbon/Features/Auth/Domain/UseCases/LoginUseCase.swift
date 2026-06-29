//
//  LoginUseCase.swift
//  Binbon
//
//  Domain layer — authenticates a user with email/password credentials.
//

import Foundation

struct LoginUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    func execute(request: LoginUserRequest) async throws -> UserResponse {
        try await repository.login(request: request)
    }
}
