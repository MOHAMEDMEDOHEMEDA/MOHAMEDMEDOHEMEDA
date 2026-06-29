
//
//  AppDIContainer+Verification.swift
//  Binbon
//
//  Composition root — Verification feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeVerificationRemoteDataSource() -> VerificationRemoteDataSource {
        MockVerificationRemoteDataSource()
    }

    func makeVerificationRepository() -> VerificationRepositoryProtocol {
        VerificationRepositoryImpl(remote: makeVerificationRemoteDataSource())
    }

    // MARK: - Use cases

    func makeCreateVerificationPaymentIntentUseCase() -> CreateVerificationPaymentIntentUseCase {
        CreateVerificationPaymentIntentUseCase(repository: makeVerificationRepository())
    }

    func makeSubmitVerificationUseCase() -> SubmitVerificationUseCase {
        SubmitVerificationUseCase(repository: makeVerificationRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeVerificationViewModel() -> VerificationViewModel {
        VerificationViewModel(
            createPaymentIntentUseCase: makeCreateVerificationPaymentIntentUseCase(),
            submitVerificationUseCase: makeSubmitVerificationUseCase()
        )
    }
}
