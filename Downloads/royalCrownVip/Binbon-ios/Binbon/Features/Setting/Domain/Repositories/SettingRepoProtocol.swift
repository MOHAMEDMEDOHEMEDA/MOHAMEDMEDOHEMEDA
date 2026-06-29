//
//  SettingRepoProtocol.swift
//  Binbon
//
//  Created by Mrwan hany on 15/06/2026.
//
//  Domain layer — settings repository boundary shared across the Setting feature
//  (account, privacy, security, content, live, data, story, support, legal, …).
//

import UIKit

protocol SettingRepoProtocol {
    func fetchProfileSetting() async -> Result<BaseResponse<AccountSettingResponse>, APIError>
    func uploadAvatar(image: UIImage) async -> Result<BaseResponse<UploadedAvatarResponse>, APIError>
    func deleteAvatar(id: Int) async -> Result<BaseResponse<DeleteAvatarResponse>, APIError>
    func deviceLogout(id: Int) async -> Result<BaseResponse<AccountSettingResponse>, APIError>
    func deviceLogoutAll() async -> Result<BaseResponse<AccountSettingResponse>, APIError>
    func addUserLink(request: AccountLinkRequest) async -> Result<BaseResponse<[AccountLinkRequest]>, APIError>
    func deleteUserLink(id: Int) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func patchProfileSetting(request: SaveAccountRequest) async -> Result<BaseResponse<AccountSettingResponse>, APIError>
    func showPrivacySetting() async -> Result<BaseResponse<PrivacySettingModel>, APIError>
    func patchPrivacySetting(request: PrivacySettingModel) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func securitySetting() async -> Result<BaseResponse<SecuritySettingResponse>, APIError>
    func enable2FAuth(channel: String) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func disbale2FAuth(password: String) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func verify2FAuth(otp: String) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func updateBiometric(request: BiometricUpdateRequest) async -> Result<BaseResponse<SecuritySettingResponse>, APIError>
    func securityActivity(page: Int) async -> Result<BaseResponse<SecurityActivityResponse>, APIError>
    func loginHistory(page: Int) async -> Result<BaseResponse<LoginHistoryResponse>, APIError>
    func fetchContentControlSettings() async -> Result<BaseResponse<ContentControlSettings>, APIError>
    func patchContentControlSettings(request: ContentControlUpdateRequest) async -> Result<BaseResponse<ContentControlSettings>, APIError>
    func fetchLiveStreamSettings() async -> Result<BaseResponse<LiveStreamSettingResponse>, APIError>
    func patchLiveStreamSettings(request: LiveStreamUpdateRequest) async -> Result<BaseResponse<LiveStreamSettingResponse>, APIError>
    func fetchLiveSchedules() async -> Result<BaseResponse<LiveScheduleListResponse>, APIError>
    func createLiveSchedule(request: LiveScheduleRequest) async -> Result<BaseResponse<LiveSchedule>, APIError>
    func deleteLiveSchedule(id: Int) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func fetchSettingsUserDataStorage() async -> Result<BaseResponse<DataStorageSettingsResponse>, APIError>
    func patchSettingsUserDataStorage(request: UpdateDataStorageSettingsRequest) async -> Result<BaseResponse<DataStorageSettingsResponse>, APIError>
    func clearCache() async -> Result<BaseResponse<EmptyResponse>, APIError>
    func deleteMyAccount() async -> Result<BaseResponse<EmptyResponse>, APIError>
    func fetchStorySettings() async -> Result<BaseResponse<StorySettingsResponse>, APIError>
    func patchStorySettings(request: StorySettingsRequest) async -> Result<BaseResponse<StorySettingsResponse>, APIError>
    func exportPersonalData() async -> Result<BaseResponse<EmptyResponse>, APIError>
    func fetchSupportFaqs() async -> Result<BaseResponse<[SupportFAQ]>, APIError>
    func sendSuggestion(message: String) async -> Result<BaseResponse<SupportSuggestion>, APIError>
    func sendReport(message: String) async -> Result<BaseResponse<SupportTicket>, APIError>
    func interactionSetting() async -> Result<BaseResponse<InteractionSettings>, APIError>
    func updateInteractionSettings(updateInteractionSettings: UpdateInteractionSettings) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func fetchBlockedUsers(request: BlockedUsersRequest) async -> Result<BlockedUsersResponse, APIError>
    func blockUser(username: String) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func unblockUser(id: Int) async -> Result<BaseResponse<EmptyResponse>, APIError>
    func fetchLegalSettings() async -> Result<BaseResponse<LegalContent>, APIError>
    func fetchAdsSettings() async -> Result<BaseResponse<AdsSettingResponse>, APIError>
    func patchAdsSettings(request: AdsSettingRequest) async -> Result<BaseResponse<AdsSettingResponse>, APIError>
}
