//
//  ShareViewModel.swift
//  Binbon
//

import Foundation
import Combine

@MainActor
final class ShareViewModel: ObservableObject {

    /// Suggested contacts shown in the sheet's top row. Empty until `load()`
    /// resolves; the destination rows render regardless, so there's no blocking
    /// state for them.
    @Published private(set) var contacts: [ShareContact] = []
    @Published var isLoading = false
    @Published var error: APIError?

    private let fetchContactsUseCase: FetchShareContactsUseCase

    init(fetchContactsUseCase: FetchShareContactsUseCase) {
        self.fetchContactsUseCase = fetchContactsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(fetchContactsUseCase: container.makeFetchShareContactsUseCase())
    }

    func load() {
        isLoading = true
        Task {
            do {
                self.contacts = try await fetchContactsUseCase.execute()
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
            isLoading = false
        }
    }
}
