//
//  LiveStreamSettingRepositoryProtocol.swift
//  Binbon
//
//  Domain layer — live stream settings boundary the use cases depend on.
//  Returns reused app models as entities and throws `APIError`.
//

import Foundation

protocol LiveStreamSettingRepositoryProtocol {
    func fetchLiveStreamSettings() async throws -> LiveStreamSettingResponse
    /// Returns the updated settings plus the server message for the success toast.
    func updateLiveStreamSettings(request: LiveStreamUpdateRequest) async throws -> (settings: LiveStreamSettingResponse, message: String?)
    func fetchLiveSchedules() async throws -> LiveScheduleListResponse
    /// Returns the server message so the UI can surface it in a toast.
    func createLiveSchedule(request: LiveScheduleRequest) async throws -> String?
    /// Returns the server message so the UI can surface it in a toast.
    func deleteLiveSchedule(id: Int) async throws -> String?
}
