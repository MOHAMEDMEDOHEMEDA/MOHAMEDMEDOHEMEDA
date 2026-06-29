//
//  SecuritySettingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — security settings boundary the use cases depend on. Returns the
//  reused app entities and throws `APIError`; the transport envelope never leaks here.
//

import Foundation

protocol SecuritySettingRepositoryProtocol {
    func fetchSecuritySettings() async throws -> SecuritySettingResponse
    func updateBiometric(request: BiometricUpdateRequest) async throws -> SecuritySettingResponse
    func disable2FA(password: String) async throws
    func fetchSecurityActivity(page: Int) async throws -> SecurityActivityResponse
    func fetchLoginHistory(page: Int) async throws -> LoginHistoryResponse
}
