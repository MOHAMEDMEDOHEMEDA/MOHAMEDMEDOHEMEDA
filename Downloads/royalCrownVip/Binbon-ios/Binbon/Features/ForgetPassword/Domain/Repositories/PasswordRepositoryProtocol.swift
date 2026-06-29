//
//  PasswordRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — password-reset boundary the use cases depend on. Each operation
//  completes on success or throws `APIError`.
//

import Foundation

protocol PasswordRepositoryProtocol {
    func forgetPassword(request: PasswordRequest) async throws
    func verifyResetCode(request: PasswordRequest) async throws
    func resetPassword(request: PasswordRequest) async throws
}
