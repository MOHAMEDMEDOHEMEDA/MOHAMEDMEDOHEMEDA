//
//  CreateVerificationPaymentIntentUseCase.swift
//  Binbon
//
//  Domain layer — prepares the payment step of identity verification.
//

import Foundation

struct CreateVerificationPaymentIntentUseCase {
    private let repository: VerificationRepositoryProtocol

    init(repository: VerificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> PaymentIntentResponse {
        try await repository.createVerificationPaymentIntent()
    }
}
