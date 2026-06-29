//
//  LegalSettingsViewModel.swift
//  Binbon
//
//  Created by heba elcc on 07/06/2026.
//

import UIKit
import Combine

@MainActor
final class LegalSettingsViewModel: ObservableObject {

    // MARK: - Data
    @Published var termsAndConditions: LegalSectionContent?
    @Published var privacyPolicy: LegalSectionContent?
    @Published var fairUsePolicy: LegalSectionContent?
    @Published var intellectualPropertyRights: LegalSectionContent?
    @Published var dataDeletionRequest: LegalSectionContent?

    // MARK: - UI State
    @Published var error: APIError?
    @Published var isLoading: Bool = false

    private let fetchLegalSettingsUseCase: FetchLegalSettingsUseCase

    init(fetchLegalSettingsUseCase: FetchLegalSettingsUseCase) {
        self.fetchLegalSettingsUseCase = fetchLegalSettingsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(fetchLegalSettingsUseCase: container.makeFetchLegalSettingsUseCase())
    }

    // MARK: - Fetch
    func fetchLegalSettings() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let content = try await fetchLegalSettingsUseCase.execute()
                self.termsAndConditions = content.termsAndConditions
                self.privacyPolicy = content.privacyPolicy
                self.fairUsePolicy = content.fairUsePolicy
                self.intellectualPropertyRights = content.intellectualPropertyRights
                self.dataDeletionRequest = content.dataDeletionRequest
                error = nil
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }
}
