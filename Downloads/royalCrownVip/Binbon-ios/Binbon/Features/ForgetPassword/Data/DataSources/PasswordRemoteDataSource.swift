//
//  PasswordRemoteDataSource.swift
//  Binbon
//
//  Data layer — transport boundary for password reset. Mock-backed for now.
//

import Foundation

protocol PasswordRemoteDataSource {
    func forgetPassword(request: PasswordRequest) async throws
    func verifyResetCode(request: PasswordRequest) async throws
    func resetPassword(request: PasswordRequest) async throws
}

// MARK: - Mock

struct MockPasswordRemoteDataSource: PasswordRemoteDataSource {
    func forgetPassword(request: PasswordRequest) async throws {}
    func verifyResetCode(request: PasswordRequest) async throws {}
    func resetPassword(request: PasswordRequest) async throws {}
}
