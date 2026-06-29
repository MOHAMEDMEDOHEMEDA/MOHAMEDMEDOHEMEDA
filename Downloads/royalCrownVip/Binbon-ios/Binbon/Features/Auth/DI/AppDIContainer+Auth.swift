//
//  AppDIContainer+Auth.swift
//  Binbon
//
//  Composition root — Auth feature factories. All Auth wiring lives here so the
//  graph (data source → repository → use cases → view model) is assembled in one
//  place. Swap `MockAuthRemoteDataSource` for a live data source here when the API
//  comes online; nothing else changes.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeAuthRemoteDataSource() -> AuthRemoteDataSource {
        MockAuthRemoteDataSource()
    }

    func makeAuthRepository() -> AuthRepositoryProtocol {
        AuthRepositoryImpl(remote: makeAuthRemoteDataSource(), storage: storage)
    }

    // MARK: - Use cases

    func makeLoginUseCase() -> LoginUseCase {
        LoginUseCase(repository: makeAuthRepository())
    }

    func makeRegisterUseCase() -> RegisterUseCase {
        RegisterUseCase(repository: makeAuthRepository())
    }

    func makeSendOtpUseCase() -> SendOtpUseCase {
        SendOtpUseCase(repository: makeAuthRepository())
    }

    func makeVerifyOtpUseCase() -> VerifyOtpUseCase {
        VerifyOtpUseCase(repository: makeAuthRepository())
    }

    func makeSocialLoginUseCase() -> SocialLoginUseCase {
        SocialLoginUseCase(repository: makeAuthRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(
            loginUseCase: makeLoginUseCase(),
            registerUseCase: makeRegisterUseCase(),
            sendOtpUseCase: makeSendOtpUseCase(),
            verifyOtpUseCase: makeVerifyOtpUseCase(),
            socialLoginUseCase: makeSocialLoginUseCase()
        )
    }
}
