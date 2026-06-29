//
//  PasswordUseCases.swift
//  Binbon
//
//  Domain layer — password-reset flow use cases.
//

import Foundation

struct RequestPasswordResetUseCase {
    private let repository: PasswordRepositoryProtocol
    init(repository: PasswordRepositoryProtocol) { self.repository = repository }
    func execute(request: PasswordRequest) async throws {
        try await repository.forgetPassword(request: request)
    }
}

struct VerifyResetCodeUseCase {
    private let repository: PasswordRepositoryProtocol
    init(repository: PasswordRepositoryProtocol) { self.repository = repository }
    func execute(request: PasswordRequest) async throws {
        try await repository.verifyResetCode(request: request)
    }
}

struct ResetPasswordUseCase {
    private let repository: PasswordRepositoryProtocol
    init(repository: PasswordRepositoryProtocol) { self.repository = repository }
    func execute(request: PasswordRequest) async throws {
        try await repository.resetPassword(request: request)
    }
}
