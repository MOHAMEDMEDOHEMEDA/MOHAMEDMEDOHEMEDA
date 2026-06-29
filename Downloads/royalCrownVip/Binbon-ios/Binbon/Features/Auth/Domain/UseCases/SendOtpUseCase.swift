//
//  SendOtpUseCase.swift
//  Binbon
//
//  Domain layer — requests an email verification code for the given address.
//

import Foundation

struct SendOtpUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String) async throws {
        try await repository.sendOtp(email: email)
    }
}
