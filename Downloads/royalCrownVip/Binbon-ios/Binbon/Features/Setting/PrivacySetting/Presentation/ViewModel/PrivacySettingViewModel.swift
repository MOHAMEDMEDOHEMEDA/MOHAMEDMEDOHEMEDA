//
//  PrivacySettingViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 22/05/2026.
//

import SwiftUI
import Combine

@MainActor
class PrivacySettingViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var isLoading = false
    @Published var error: APIError?
    
    @Published var onlineCase: ProfilePrivacyEnum = .everyone
    @Published var profileCase: ProfilePrivacyEnum = .everyone
    @Published var friendCase: FriendPrivacyEnum = .everyone
    @Published var privateMessageCase: PrivacySettingEnum = .everyone
    @Published var commentCase: PrivacySettingEnum = .everyone
    @Published var mentionCase: PrivacySettingEnum = .everyone
    @Published var storyCase: PrivacySettingEnum = .everyone
    @Published var shareCase: PrivacySettingEnum = .everyone
    @Published var activeCase: PrivacySettingEnum = .everyone
    @Published var incognitoCase: Bool = false
    
    var privacyModel: PrivacySettingModel?
    
    // MARK: - Properties
    private let fetchPrivacySettingUseCase: FetchPrivacySettingUseCase
    private let updatePrivacySettingUseCase: UpdatePrivacySettingUseCase

    init(
        fetchPrivacySettingUseCase: FetchPrivacySettingUseCase,
        updatePrivacySettingUseCase: UpdatePrivacySettingUseCase
    ) {
        self.fetchPrivacySettingUseCase = fetchPrivacySettingUseCase
        self.updatePrivacySettingUseCase = updatePrivacySettingUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchPrivacySettingUseCase: container.makeFetchPrivacySettingUseCase(),
            updatePrivacySettingUseCase: container.makeUpdatePrivacySettingUseCase()
        )
    }


    // MARK: - Lifecycle Methods
    func fetchPrivacySettings() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                let model = try await fetchPrivacySettingUseCase.execute()
                mapResponseToProperties(model)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    func save() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            let request = PrivacySettingModel(
                id: privacyModel?.id,
                userId: privacyModel?.userId,
                profileVisibility: profileCase.rawValue,
                onlineTimeVisibility: onlineCase.rawValue,
                friendRequestPrivacy: friendCase.rawValue,
                dmPrivacy: privateMessageCase.rawValue,
                commentPrivacy: commentCase.rawValue,
                mentionPrivacy: mentionCase.rawValue,
                storyPrivacy: storyCase.rawValue,
                sharePostPrivacy: shareCase.rawValue,
                activityStatusVisibility: activeCase.rawValue,
                incognitoMode: incognitoCase
            )

            do {
                let message = try await updatePrivacySettingUseCase.execute(request: request)
                Toaster.shared.show(.success(), message ?? "privacy_settings_updated".localized)
                AppRouter.shared.back()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func isDataNoChanges() -> Bool {
        guard let model = privacyModel else { return true }
        
        let onlineMatches = model.onlineTimeVisibility == onlineCase.rawValue
        let profileMatches = model.profileVisibility == profileCase.rawValue
        let friendMatches = model.friendRequestPrivacy == friendCase.rawValue
        let privateMessageMatches = model.dmPrivacy == privateMessageCase.rawValue
        let commentMatches = model.commentPrivacy == commentCase.rawValue
        let mentionMatches = model.mentionPrivacy == mentionCase.rawValue
        let storyMatches = model.storyPrivacy == storyCase.rawValue
        let shareMatches = model.sharePostPrivacy == shareCase.rawValue
        let activeMatches = model.activityStatusVisibility == activeCase.rawValue
        let incognitoMatches = model.incognitoMode == incognitoCase
        
        return onlineMatches && profileMatches && friendMatches && 
               privateMessageMatches && commentMatches && mentionMatches &&
               storyMatches && shareMatches && activeMatches && incognitoMatches
    }
    
    // MARK: - Helper Methods
    private func mapResponseToProperties(_ response: PrivacySettingModel?) {
        
        privacyModel = response
        
        if let value = response?.onlineTimeVisibility {
            onlineCase = ProfilePrivacyEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.profileVisibility {
            profileCase = ProfilePrivacyEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.friendRequestPrivacy {
            friendCase = FriendPrivacyEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.dmPrivacy {
            privateMessageCase = PrivacySettingEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.commentPrivacy {
            commentCase = PrivacySettingEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.mentionPrivacy {
            mentionCase = PrivacySettingEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.storyPrivacy {
            storyCase = PrivacySettingEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.sharePostPrivacy {
            shareCase = PrivacySettingEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.activityStatusVisibility {
            activeCase = PrivacySettingEnum(rawValue: value) ?? .everyone
        }
        
        if let value = response?.incognitoMode {
            incognitoCase = value
        }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }

}
