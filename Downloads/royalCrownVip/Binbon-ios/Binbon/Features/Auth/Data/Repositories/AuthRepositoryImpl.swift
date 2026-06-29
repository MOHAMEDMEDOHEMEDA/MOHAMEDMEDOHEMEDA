//
//  AuthRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `AuthRepositoryProtocol`. Drives the remote data source,
//  unwraps the response envelope, persists the session on success, and surfaces
//  failures as `APIError` so the envelope never escapes into the domain.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol {

    private let remote: AuthRemoteDataSource
    private let storage: Storage

    init(remote: AuthRemoteDataSource, storage: Storage = .shared) {
        self.remote = remote
        self.storage = storage
    }

    func login(request: LoginUserRequest) async throws -> UserResponse {
        try persistSession(from: await remote.login(request: request))
    }

    func register(request: RegisterUserRequest) async throws -> UserResponse {
        try persistSession(from: await remote.register(request: request))
    }

    func sendOtp(email: String) async throws {
        try ensureSuccess(await remote.sendOtp(email: email))
    }

    func verifyOtp(email: String, otp: String) async throws {
        try ensureSuccess(await remote.verifyOtp(email: email, otp: otp))
    }

    func socialLogin(provider: SocialProvider, token: String) async throws -> UserResponse {
        try persistSession(from: await remote.socialLogin(provider: provider, token: token))
    }

    // MARK: - Helpers

    /// Validates the envelope, stores the authenticated user + token, and returns
    /// the user entity.
    @discardableResult
    private func persistSession(from response: BaseResponse<UserResponse>) throws -> UserResponse {
        guard response.status == true, let user = response.data else {
            throw APIError(type: .backend, message: response.message)
        }
        storage.user = user
        storage.token = user.token?.authToken
        return user
    }

    /// Validates a dataless envelope, throwing on a non-successful status.
    private func ensureSuccess(_ response: BaseResponse<EmptyResponse>) throws {
        guard response.status == true else {
            throw APIError(type: .backend, message: response.message)
        }
    }
}
