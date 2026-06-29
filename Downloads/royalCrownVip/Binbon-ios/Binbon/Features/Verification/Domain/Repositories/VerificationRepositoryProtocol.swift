//
//  VerificationRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — identity-verification boundary the use cases depend on. Returns
//  entities and throws `APIError`; the concrete implementation lives in Data.
//

import Foundation

protocol VerificationRepositoryProtocol {
    /// Sets up the payment step. Returns the intent describing whether payment is
    /// required and the Stripe client secret to drive the sheet.
    func createVerificationPaymentIntent() async throws -> PaymentIntentResponse

    /// Submits the collected KYC details and document images.
    func submitVerification(request: SubmitVerificationRequest) async throws
}
