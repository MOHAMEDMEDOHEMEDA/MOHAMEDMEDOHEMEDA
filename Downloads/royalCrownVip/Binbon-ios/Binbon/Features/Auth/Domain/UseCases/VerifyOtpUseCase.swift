//
//  VerifyOtpUseCase.swift
//  Binbon
//
//  Domain layer — validates the email verification code entered by the user.
//

import Foundation

struct VerifyOtpUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(email: String, otp: String) async throws {
        try await repository.verifyOtp(email: email, otp: otp)
    }
}
