//
//  HomeViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {

    // MARK: - Published
    @Published var user: UserResponse?

    // MARK: - Use cases
    private let getCurrentUserUseCase: GetCurrentUserUseCase

    init(getCurrentUserUseCase: GetCurrentUserUseCase) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.user = getCurrentUserUseCase.execute()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(getCurrentUserUseCase: container.makeGetCurrentUserUseCase())
    }
}
