//
//  PasswordRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `PasswordRepositoryProtocol`, driving the remote data source.
//

import Foundation

final class PasswordRepositoryImpl: PasswordRepositoryProtocol {

    private let remote: PasswordRemoteDataSource

    init(remote: PasswordRemoteDataSource) {
        self.remote = remote
    }

    func forgetPassword(request: PasswordRequest) async throws {
        try await remote.forgetPassword(request: request)
    }

    func verifyResetCode(request: PasswordRequest) async throws {
        try await remote.verifyResetCode(request: request)
    }

    func resetPassword(request: PasswordRequest) async throws {
        try await remote.resetPassword(request: request)
    }
}
