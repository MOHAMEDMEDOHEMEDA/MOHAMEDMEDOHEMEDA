//
//  GetCurrentUserUseCase.swift
//  Binbon
//
//  Domain layer — reads the current user from local storage.
//

import Foundation

struct GetCurrentUserUseCase {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> UserResponse? {
        repository.currentUser()
    }
}
