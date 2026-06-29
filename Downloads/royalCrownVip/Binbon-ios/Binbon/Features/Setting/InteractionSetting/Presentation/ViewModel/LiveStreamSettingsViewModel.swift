//
//  LiveStreamSettingsViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 07/06/2026.
//

import SwiftUI
import Combine

@MainActor
class LiveStreamSettingsViewModel: ObservableObject {
    @Published var error: APIError?
    
    @Published var commentsAllowance: CommentsAllowance = .allow
    @Published var giftsEnabled = true
    
    @Published var liveVisibility: LiveVisibility = .everyone
    @Published var liveType: LiveStreamType = .public
    
    @Published var livePassword = ""
    @Published var livePasswordEnabled = false
    
    @Published var audienceUsers: [LiveAudienceUser] = []
    
    private let fetchLiveStreamSettingsUseCase: FetchInteractionLiveStreamSettingsUseCase
    private let updateLiveStreamSettingsUseCase: UpdateInteractionLiveStreamSettingsUseCase

    init(
        fetchLiveStreamSettingsUseCase: FetchInteractionLiveStreamSettingsUseCase,
        updateLiveStreamSettingsUseCase: UpdateInteractionLiveStreamSettingsUseCase
    ) {
        self.fetchLiveStreamSettingsUseCase = fetchLiveStreamSettingsUseCase
        self.updateLiveStreamSettingsUseCase = updateLiveStreamSettingsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchLiveStreamSettingsUseCase: container.makeFetchInteractionLiveStreamSettingsUseCase(),
            updateLiveStreamSettingsUseCase: container.makeUpdateInteractionLiveStreamSettingsUseCase()
        )
    }

    func fetchLiveStreamSettings() {
        Task {
            do {
                let data = try await fetchLiveStreamSettingsUseCase.execute()

                commentsAllowance = CommentsAllowance(enabled: data.commentsEnabled ?? false)
                giftsEnabled = data.giftsEnabled ?? false
                liveVisibility = LiveVisibility(rawValue: data.liveVisibility ?? 0) ?? .everyone
                liveType = LiveStreamType(rawValue: data.liveType ?? 0) ?? .public
                livePasswordEnabled = data.livePasswordEnabled ?? false
                audienceUsers = data.items ?? []
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    func updateLiveStreamSettings() async {

        let request = LiveStreamUpdateRequest(
            commentsEnabled: commentsAllowance.isEnabled,
            giftsEnabled: giftsEnabled,
            liveVisibility: liveVisibility.rawValue,
            liveType: liveType.rawValue,
            livePassword: livePassword.isEmpty ? nil : livePassword,
            clearLivePassword: false
        )

        do {
            let data = try await updateLiveStreamSettingsUseCase.execute(request)
            livePasswordEnabled = data.livePasswordEnabled ?? false
        } catch {
            self.error = asAPIError(error)
        }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
