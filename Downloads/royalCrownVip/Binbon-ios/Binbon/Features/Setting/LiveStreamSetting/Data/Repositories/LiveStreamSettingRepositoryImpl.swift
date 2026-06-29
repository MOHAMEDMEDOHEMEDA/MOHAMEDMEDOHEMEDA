//
//  LiveStreamSettingRepositoryImpl.swift
//  Binbon
//
//  Data layer — concrete `LiveStreamSettingRepositoryProtocol`. Wraps the shared
//  `SettingRepo`, unwrapping the transport envelope so the domain only sees
//  entities.
//

import Foundation

final class LiveStreamSettingRepositoryImpl: LiveStreamSettingRepositoryProtocol {

    private let settingRepo: SettingRepoProtocol

    init(settingRepo: SettingRepoProtocol) {
        self.settingRepo = settingRepo
    }

    func fetchLiveStreamSettings() async throws -> LiveStreamSettingResponse {
        switch await settingRepo.fetchLiveStreamSettings() {
        case .success(let response):
            guard let settings = response.data else {
                throw APIError(type: .parsing, message: "Empty live stream settings")
            }
            return settings
        case .failure(let error):
            throw error
        }
    }

    func updateLiveStreamSettings(request: LiveStreamUpdateRequest) async throws -> (settings: LiveStreamSettingResponse, message: String?) {
        switch await settingRepo.patchLiveStreamSettings(request: request) {
        case .success(let response):
            guard let settings = response.data else {
                throw APIError(type: .parsing, message: "Empty live stream settings")
            }
            return (settings, response.message)
        case .failure(let error):
            throw error
        }
    }

    func fetchLiveSchedules() async throws -> LiveScheduleListResponse {
        switch await settingRepo.fetchLiveSchedules() {
        case .success(let response):
            guard let list = response.data else {
                throw APIError(type: .parsing, message: "Empty live schedules")
            }
            return list
        case .failure(let error):
            throw error
        }
    }

    func createLiveSchedule(request: LiveScheduleRequest) async throws -> String? {
        switch await settingRepo.createLiveSchedule(request: request) {
        case .success(let response):
            return response.message
        case .failure(let error):
            throw error
        }
    }

    func deleteLiveSchedule(id: Int) async throws -> String? {
        switch await settingRepo.deleteLiveSchedule(id: id) {
        case .success(let response):
            return response.message
        case .failure(let error):
            throw error
        }
    }
}
