//
//  AdsSettingViewModel.swift
//  Binbon
//
//  Created by Mahmoud ِElsharkawy on 18/06/2026.
//

import Foundation
import Combine

@MainActor
class AdsSettingViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var error: APIError?
    @Published var adTypes: [AdType] = []

    private var originalAdTypes: [AdType] = []
    private let fetchAdsSettingsUseCase: FetchAdsSettingsUseCase
    private let updateAdsSettingsUseCase: UpdateAdsSettingsUseCase

    init(
        fetchAdsSettingsUseCase: FetchAdsSettingsUseCase,
        updateAdsSettingsUseCase: UpdateAdsSettingsUseCase
    ) {
        self.fetchAdsSettingsUseCase = fetchAdsSettingsUseCase
        self.updateAdsSettingsUseCase = updateAdsSettingsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchAdsSettingsUseCase: container.makeFetchAdsSettingsUseCase(),
            updateAdsSettingsUseCase: container.makeUpdateAdsSettingsUseCase()
        )
    }

    func fetchAdsSettings() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                let response = try await fetchAdsSettingsUseCase.execute()
                adTypes = response.adTypes
                originalAdTypes = adTypes
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

            do {
                let response = try await updateAdsSettingsUseCase.execute(request: AdsSettingRequest(adTypes: adTypes))
                adTypes = response.adTypes
                originalAdTypes = adTypes
                Toaster.shared.show(.success(), "ads_settings_updated".localized)
                AppRouter.shared.back()
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }

    func isDataNoChanges() -> Bool {
        adTypes == originalAdTypes
    }
}
