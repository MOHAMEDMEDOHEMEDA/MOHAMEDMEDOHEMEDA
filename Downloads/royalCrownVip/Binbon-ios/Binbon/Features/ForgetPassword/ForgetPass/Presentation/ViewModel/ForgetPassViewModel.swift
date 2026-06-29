//
//  ForgetPassViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import Foundation
import Combine

@MainActor
class ForgetPassViewModel: ObservableObject {
    
    /// Which identifier the user recovers with.
    enum RecoveryMethod { case phone, email }

    // MARK: - Published
    @Published var error: APIError?
    @Published var isLoading: Bool = false
    @Published var method: RecoveryMethod = .phone
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var country: Country = .default
    @Published var dialCode = Country.default.dialCode
    private let requestPasswordResetUseCase: RequestPasswordResetUseCase

    init(requestPasswordResetUseCase: RequestPasswordResetUseCase) {
        self.requestPasswordResetUseCase = requestPasswordResetUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(requestPasswordResetUseCase: container.makeRequestPasswordResetUseCase())
    }

    // MARK: - Methods
    func onNext() {

        // Validate the active identifier and use it as the recovery handle —
        // the endpoint takes a single `user_email` field for email or phone.
        let identifier: String
        switch method {
        case .email:
            if let error = FormValidation.email(email) {
                self.error = APIError(type: .request, message: error)
                return
            }
            identifier = email
        case .phone:
            if let error = FormValidation.phoneDigits(phoneNumber) {
                self.error = APIError(type: .request, message: error)
                return
            }
            identifier = dialCode + phoneNumber
        }

        let request = PasswordRequest(email: identifier)

        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await requestPasswordResetUseCase.execute(request: request)
                Toaster.shared.show(.success("staroflife.circle"), "reset_code_sent".localized)
                AppRouter.shared.navigate(.verifyOTP(request))
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
        
    }
}
