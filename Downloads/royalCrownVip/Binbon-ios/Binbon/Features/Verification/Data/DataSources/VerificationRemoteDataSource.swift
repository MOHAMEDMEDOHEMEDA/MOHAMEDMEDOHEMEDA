//
//  VerificationRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for identity verification. Mock-backed during
//  the current pre-integration phase.
//

import Foundation

protocol VerificationRemoteDataSource {
    func createVerificationPaymentIntent() async throws -> PaymentIntentResponse
    func submitVerification(request: SubmitVerificationRequest) async throws
}

// MARK: - Mock

struct MockVerificationRemoteDataSource: VerificationRemoteDataSource {

    func createVerificationPaymentIntent() async throws -> PaymentIntentResponse {
        .mock
    }

    func submitVerification(request: SubmitVerificationRequest) async throws {}
}

private extension PaymentIntentResponse {
    static let mock = PaymentIntentResponse(
        paymentRequired: false,
        paymentIntentId: nil,
        clientSecret: nil,
        publishableKey: nil,
        amount: nil,
        currency: nil
    )
}
