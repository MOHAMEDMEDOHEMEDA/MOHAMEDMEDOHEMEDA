//
//  FetchShareContactsUseCase.swift
//  Binbon
//
//  Domain layer — loads the contacts suggested for sharing.
//

import Foundation

struct FetchShareContactsUseCase {
    private let repository: ShareRepositoryProtocol

    init(repository: ShareRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ShareContact] {
        try await repository.fetchContacts()
    }
}
