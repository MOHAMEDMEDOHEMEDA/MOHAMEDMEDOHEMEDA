//
//  AuthRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — the authentication boundary the use cases depend on. Methods
//  return domain entities (the app's `UserResponse` model is reused as the user
//  entity) and throw `APIError` on failure; the transport envelope
//  (`BaseResponse`) never leaks past this boundary.
//

import Foundation

protocol AuthRepositoryProtocol {
    func login(request: LoginUserRequest) async throws -> UserResponse
    func register(request: RegisterUserRequest) async throws -> UserResponse
    func sendOtp(email: String) async throws
    func verifyOtp(email: String, otp: String) async throws
    func socialLogin(provider: SocialProvider, token: String) async throws -> UserResponse
}
