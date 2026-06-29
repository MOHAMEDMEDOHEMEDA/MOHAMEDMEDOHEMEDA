//
//  RegisterUseCase.swift
//  Binbon
//
//  Domain layer — registers a new account from the collected registration data.
//

import Foundation

struct RegisterUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    func execute(request: RegisterUserRequest) async throws -> UserResponse {
        try await repository.register(request: request)
    }
}
