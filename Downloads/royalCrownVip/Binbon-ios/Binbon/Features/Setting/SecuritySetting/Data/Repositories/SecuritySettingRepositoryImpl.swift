//
//  SecuritySettingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `SecuritySettingRepositoryProtocol`. Wraps the shared
//  `SettingRepo`, unwrapping the transport envelope so the domain only sees entities.
//

import Foundation

final class SecuritySettingRepositoryImpl: SecuritySettingRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchSecuritySettings() async throws -> SecuritySettingResponse {
        switch await settingRepo.securitySetting() {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty security settings")
            }
            return data
        case .failure(let error):
            throw error
        }
    }

    func updateBiometric(request: BiometricUpdateRequest) async throws -> SecuritySettingResponse {
        switch await settingRepo.updateBiometric(request: request) {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty biometric response")
            }
            return data
        case .failure(let error):
            throw error
        }
    }

    func disable2FA(password: String) async throws {
        switch await settingRepo.disbale2FAuth(password: password) {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func fetchSecurityActivity(page: Int) async throws -> SecurityActivityResponse {
        switch await settingRepo.securityActivity(page: page) {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty security activity")
            }
            return data
        case .failure(let error):
            throw error
        }
    }

    func fetchLoginHistory(page: Int) async throws -> LoginHistoryResponse {
        switch await settingRepo.loginHistory(page: page) {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty login history")
            }
            return data
        case .failure(let error):
            throw error
        }
    }
}
