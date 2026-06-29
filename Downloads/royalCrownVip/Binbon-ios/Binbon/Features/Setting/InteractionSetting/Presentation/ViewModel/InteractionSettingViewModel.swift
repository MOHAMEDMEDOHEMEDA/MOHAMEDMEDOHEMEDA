//
//  InteractionSettingViewModel.swift
//  Binbon
//
//  Created by Aya Mashaly on 03/06/2026.
//

import SwiftUI
import Combine

@MainActor
class InteractionSettingViewModel: ObservableObject {
    
    // MARK: - Published (Interaction Settings)
    @Published var isLoading = false
    @Published var error: APIError?
    
    @Published var allowComments: Bool = false
    @Published var allowMediaMessages: Bool = false
    @Published var mediaMessagesPermission: InteractionPermission = .everyone
    @Published var commentsPermission: InteractionPermission = .everyone
    @Published var mentionsPermission: InteractionPermission = .everyone
    @Published var allowGifts: Bool = true
    
    // MARK: - Published (Payment Methods)
    @Published var paymentCards: [PaymentCard] = []
    
    @Published var paymentWallets: [PaymentWallet] = [
        PaymentWallet(brandImage: "ApplePay",  title: "Apple Pay"),
        PaymentWallet(brandImage: "GooglePay", title: "Google Pay")
    ]
    
    @Published var showAddPaymentAlert = false

    // MARK: - Pagination
    private var nextCursor: String? = nil
    private var hasMore: Bool = true

    // MARK: - Private
    var interactionModel: InteractionSettings?
    private let fetchInteractionSettingsUseCase: FetchInteractionSettingsUseCase
    private let updateInteractionSettingsUseCase: UpdateInteractionSettingsUseCase

    init(
        fetchInteractionSettingsUseCase: FetchInteractionSettingsUseCase,
        updateInteractionSettingsUseCase: UpdateInteractionSettingsUseCase
    ) {
        self.fetchInteractionSettingsUseCase = fetchInteractionSettingsUseCase
        self.updateInteractionSettingsUseCase = updateInteractionSettingsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchInteractionSettingsUseCase: container.makeFetchInteractionSettingsUseCase(),
            updateInteractionSettingsUseCase: container.makeUpdateInteractionSettingsUseCase()
        )
    }


    // MARK: - Lifecycle
    func fetchInteractionSettings() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                let settings = try await fetchInteractionSettingsUseCase.execute()
                mapResponseToProperties(settings)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    func updateInteractionSettings() {
        Task {
            let request = UpdateInteractionSettings(
                allowComments: allowComments,
                allowMediaMessages: allowMediaMessages, mediaMessagesPermission: mediaMessagesPermission.apiValue,
                mentionsPermission: mentionsPermission.apiValue)

            do {
                try await updateInteractionSettingsUseCase.execute(request)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    // MARK: - Payment Methods
    func deleteCard(_ card: PaymentCard) {
        // TODO:
        paymentCards.removeAll { $0.id == card.id }
    }

    func pay(with wallet: PaymentWallet) {
        // TODO:
    }
    
    // MARK: - Save Changes
    func save() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                try await updateInteractionSettingsUseCase.execute(
                    UpdateInteractionSettings(
                        allowComments: allowComments,
                        allowMediaMessages: allowMediaMessages,
                        mediaMessagesPermission: mediaMessagesPermission.apiValue,
                        mentionsPermission: mentionsPermission.apiValue
                    )
                )
                Toaster.shared.show(.success(), "update_successfully".localized)
                AppRouter.shared.back()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func isDataNoChanges() -> Bool {
        guard let model = interactionModel else { return true }
        
        return
            model.allowComments == allowComments &&
            model.allowMediaMessages == allowMediaMessages &&
            model.mediaMessagesPermission == mediaMessagesPermission &&
            model.mentionsPermission == mentionsPermission &&
            model.commentsPermission == commentsPermission
    }
    
    // MARK: - Helpers
    private func mapResponseToProperties(_ response: InteractionSettings?) {
        interactionModel = response
        guard let response else { return }
        
        allowComments = response.allowComments
        commentsPermission = response.commentsPermission
        allowMediaMessages = response.allowMediaMessages
        mediaMessagesPermission = response.mediaMessagesPermission
        mentionsPermission = response.mentionsPermission
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
