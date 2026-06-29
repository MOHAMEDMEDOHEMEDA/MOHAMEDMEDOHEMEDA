//
//  InteractionSettingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — interaction settings boundary shared across the sub-feature
//  (interaction settings, blocked users, live stream settings). Returns the
//  reused app models as entities and throws `APIError`.
//

import Foundation

protocol InteractionSettingRepositoryProtocol {
    func fetchInteractionSettings() async throws -> InteractionSettings
    func updateInteractionSettings(_ request: UpdateInteractionSettings) async throws

    func fetchBlockedUsers(_ request: BlockedUsersRequest) async throws -> BlockedUsersResponse
    func blockUser(username: String) async throws
    func unblockUser(id: Int) async throws

    func fetchLiveStreamSettings() async throws -> LiveStreamSettingResponse
    func updateLiveStreamSettings(_ request: LiveStreamUpdateRequest) async throws -> LiveStreamSettingResponse
}
