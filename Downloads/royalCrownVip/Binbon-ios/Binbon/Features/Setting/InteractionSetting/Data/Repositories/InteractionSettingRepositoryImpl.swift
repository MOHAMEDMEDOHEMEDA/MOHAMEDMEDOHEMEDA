//
//  InteractionSettingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `InteractionSettingRepositoryProtocol`. Wraps the shared
//  `SettingRepo`, unwrapping the transport envelope so the domain only sees the
//  reused app models.
//

import Foundation

final class InteractionSettingRepositoryImpl: InteractionSettingRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchInteractionSettings() async throws -> InteractionSettings {
        switch await settingRepo.interactionSetting() {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty interaction settings")
            }
            return data
        case .failure(let error):
            throw error
        }
    }

    func updateInteractionSettings(_ request: UpdateInteractionSettings) async throws {
        switch await settingRepo.updateInteractionSettings(updateInteractionSettings: request) {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func fetchBlockedUsers(_ request: BlockedUsersRequest) async throws -> BlockedUsersResponse {
        switch await settingRepo.fetchBlockedUsers(request: request) {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    func blockUser(username: String) async throws {
        switch await settingRepo.blockUser(username: username) {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func unblockUser(id: Int) async throws {
        switch await settingRepo.unblockUser(id: id) {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }

    func fetchLiveStreamSettings() async throws -> LiveStreamSettingResponse {
        switch await settingRepo.fetchLiveStreamSettings() {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty live stream settings")
            }
            return data
        case .failure(let error):
            throw error
        }
    }

    func updateLiveStreamSettings(_ request: LiveStreamUpdateRequest) async throws -> LiveStreamSettingResponse {
        switch await settingRepo.patchLiveStreamSettings(request: request) {
        case .success(let response):
            guard let data = response.data else {
                throw APIError(type: .parsing, message: "Empty live stream settings")
            }
            return data
        case .failure(let error):
            throw error
        }
    }
}
