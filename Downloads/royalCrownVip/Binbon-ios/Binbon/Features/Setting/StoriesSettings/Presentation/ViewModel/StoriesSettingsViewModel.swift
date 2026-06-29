//
//  StoriesSettingsViewModel.swift
//  Binbon
//
//  Created by Husayn on 04/06/2026.
//

import Foundation
import Combine

@MainActor
class StoriesSettingsViewModel: ObservableObject {

    // MARK: - Published
    @Published var isLoading = false
    @Published var error: APIError?

    @Published var storyVisibilityCase: StoryPrivacyEnum = .everyone
    @Published var storyReplyCase: StoryPrivacyEnum = .everyone
    @Published var autoSaveStoriesCase: YesNoEnum = .no
    @Published var shareToOtherAccountsCase: YesNoEnum = .no

    var storySettingsResponse: StorySettingsResponse?

    // MARK: - Properties
    private let fetchStorySettingsUseCase: FetchStorySettingsUseCase
    private let updateStorySettingsUseCase: UpdateStorySettingsUseCase

    init(
        fetchStorySettingsUseCase: FetchStorySettingsUseCase,
        updateStorySettingsUseCase: UpdateStorySettingsUseCase
    ) {
        self.fetchStorySettingsUseCase = fetchStorySettingsUseCase
        self.updateStorySettingsUseCase = updateStorySettingsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchStorySettingsUseCase: container.makeFetchStorySettingsUseCase(),
            updateStorySettingsUseCase: container.makeUpdateStorySettingsUseCase()
        )
    }

    // MARK: - Methods
    func fetchStorySettings() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                mapResponse(try await fetchStorySettingsUseCase.execute())
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }

    func save() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            let request = StorySettingsRequest(
                storyVisibility: storyVisibilityCase.apiValue,
                storyReplyPermissions: storyReplyCase.apiValue,
                autoSaveStories: autoSaveStoriesCase.boolValue,
                shareToOtherAccounts: shareToOtherAccountsCase.boolValue
            )

            do {
                let response = try await updateStorySettingsUseCase.execute(request: request)
                mapResponse(response)
                Toaster.shared.show(.success(), "story_settings_updated".localized)
                AppRouter.shared.back()
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }

    func isDataNoChanges() -> Bool {
        guard let response = storySettingsResponse else { return true }

        let visibilityMatches = storyVisibilityCase == (StoryPrivacyEnum(apiValue: response.storyVisibility) ?? .everyone)
        let replyMatches = storyReplyCase == (StoryPrivacyEnum(apiValue: response.storyReplyPermissions) ?? .everyone)
        let autoSaveMatches = autoSaveStoriesCase.boolValue == response.autoSaveStories
        let shareMatches = shareToOtherAccountsCase.boolValue == response.shareToOtherAccounts

        return visibilityMatches && replyMatches && autoSaveMatches && shareMatches
    }

    // MARK: - Helper Methods
    private func mapResponse(_ response: StorySettingsResponse?) {
        storySettingsResponse = response

        if let value = response?.storyVisibility {
            storyVisibilityCase = StoryPrivacyEnum(apiValue: value) ?? .everyone
        }

        if let value = response?.storyReplyPermissions {
            storyReplyCase = StoryPrivacyEnum(apiValue: value) ?? .everyone
        }

        autoSaveStoriesCase = YesNoEnum(from: response?.autoSaveStories ?? false)
        shareToOtherAccountsCase = YesNoEnum(from: response?.shareToOtherAccounts ?? false)
    }
}
