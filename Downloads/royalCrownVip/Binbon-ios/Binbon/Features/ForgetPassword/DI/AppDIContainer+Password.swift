//
//  AppDIContainer+Password.swift
//  Binbon
//
//  Composition root — ForgetPassword feature factories.
//

import Foundation

extension AppDIContainer {

    func makePasswordRemoteDataSource() -> PasswordRemoteDataSource {
        MockPasswordRemoteDataSource()
    }

    func makePasswordRepository() -> PasswordRepositoryProtocol {
        PasswordRepositoryImpl(remote: makePasswordRemoteDataSource())
    }

    func makeRequestPasswordResetUseCase() -> RequestPasswordResetUseCase {
        RequestPasswordResetUseCase(repository: makePasswordRepository())
    }

    func makeVerifyResetCodeUseCase() -> VerifyResetCodeUseCase {
        VerifyResetCodeUseCase(repository: makePasswordRepository())
    }

    func makeResetPasswordUseCase() -> ResetPasswordUseCase {
        ResetPasswordUseCase(repository: makePasswordRepository())
    }
}
