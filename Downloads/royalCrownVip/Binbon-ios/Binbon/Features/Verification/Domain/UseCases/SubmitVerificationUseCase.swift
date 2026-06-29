//
//  SubmitVerificationUseCase.swift
//  Binbon
//
//  Domain layer — submits the collected KYC details and document images.
//

import Foundation

struct SubmitVerificationUseCase {
    private let repository: VerificationRepositoryProtocol

    init(repository: VerificationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(request: SubmitVerificationRequest) async throws {
        try await repository.submitVerification(request: request)
    }
}
