//
//  HelpAndSupportViewModel.swift
//  Binbon
//
//  Created by heba elcc on 04/06/2026.
//

import UIKit
import Combine

@MainActor
final class HelpAndSupportViewModel: ObservableObject {

    @Published var faqs: [SupportFAQ] = []
    @Published var error: APIError?
    @Published var isLoading: Bool = false

    private let fetchSupportFaqsUseCase: FetchSupportFaqsUseCase
    private let sendSuggestionUseCase: SendSuggestionUseCase
    private let sendReportUseCase: SendSupportReportUseCase

    init(
        fetchSupportFaqsUseCase: FetchSupportFaqsUseCase,
        sendSuggestionUseCase: SendSuggestionUseCase,
        sendReportUseCase: SendSupportReportUseCase
    ) {
        self.fetchSupportFaqsUseCase = fetchSupportFaqsUseCase
        self.sendSuggestionUseCase = sendSuggestionUseCase
        self.sendReportUseCase = sendReportUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchSupportFaqsUseCase: container.makeFetchSupportFaqsUseCase(),
            sendSuggestionUseCase: container.makeSendSuggestionUseCase(),
            sendReportUseCase: container.makeSendSupportReportUseCase()
        )
    }

    // MARK: - Methods
    func fetchSupportFaqs() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                self.faqs = try await fetchSupportFaqsUseCase.execute()
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }

    func sendSuggestion(message: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await sendSuggestionUseCase.execute(message: message)
            error = nil
            Toaster.shared.show(.success(), "suggestion_sent_successfully".localized)
        } catch {
            self.error = (error as? APIError) ?? Network.shared.mapError(error)
        }
    }

    func sendReport(message: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await sendReportUseCase.execute(message: message)
            error = nil
            Toaster.shared.show(.success(), "support_ticket_submitted_successfully".localized)
        } catch {
            self.error = (error as? APIError) ?? Network.shared.mapError(error)
        }
    }
}
