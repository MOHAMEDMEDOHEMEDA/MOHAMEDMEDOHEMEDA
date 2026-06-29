//
//  VerificationRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `VerificationRepositoryProtocol`, driving the remote data
//  source.
//

import Foundation

final class VerificationRepositoryImpl: VerificationRepositoryProtocol {

    private let remote: VerificationRemoteDataSource

    init(remote: VerificationRemoteDataSource) {
        self.remote = remote
    }

    func createVerificationPaymentIntent() async throws -> PaymentIntentResponse {
        try await remote.createVerificationPaymentIntent()
    }

    func submitVerification(request: SubmitVerificationRequest) async throws {
        try await remote.submitVerification(request: request)
    }
}
