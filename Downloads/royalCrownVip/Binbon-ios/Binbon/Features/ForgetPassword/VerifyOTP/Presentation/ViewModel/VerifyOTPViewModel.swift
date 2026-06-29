//
//  ForgetPassViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import Foundation
import Combine

@MainActor
class VerifyOTPViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var error: APIError?
    @Published var isLoading: Bool = false
    @Published var isResending: Bool = false
    @Published var otpCode = ""
    /// Seconds left before the resend button becomes available (0 = available).
    @Published var secondsRemaining: Int = 0

    var request = PasswordRequest()
    private let requestPasswordResetUseCase: RequestPasswordResetUseCase
    private let verifyResetCodeUseCase: VerifyResetCodeUseCase
    private var resendTimerTask: Task<Void, Never>?

    init(
        requestPasswordResetUseCase: RequestPasswordResetUseCase,
        verifyResetCodeUseCase: VerifyResetCodeUseCase
    ) {
        self.requestPasswordResetUseCase = requestPasswordResetUseCase
        self.verifyResetCodeUseCase = verifyResetCodeUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            requestPasswordResetUseCase: container.makeRequestPasswordResetUseCase(),
            verifyResetCodeUseCase: container.makeVerifyResetCodeUseCase()
        )
    }

    deinit { resendTimerTask?.cancel() }

    // MARK: - Resend cooldown
    /// Starts the resend cooldown countdown (defaults to one minute).
    func startResendTimer(_ seconds: Int = 60) {
        resendTimerTask?.cancel()
        secondsRemaining = seconds
        resendTimerTask = Task { [weak self] in
            while !Task.isCancelled, let self, self.secondsRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { break }
                self.secondsRemaining -= 1
            }
        }
    }

    // MARK: - Resend
    /// Re-requests a reset code for the same identifier as the original request.
    func resend(_ request: PasswordRequest) {
        guard !isResending else { return }
        Task {
            isResending = true
            error = nil
            defer { isResending = false }

            do {
                try await requestPasswordResetUseCase.execute(request: request)
                startResendTimer()
                Toaster.shared.show(.success("staroflife.circle"), "reset_code_sent".localized)
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }

    // MARK: - Method
    func onNext(_ request: PasswordRequest) {
        
        if let error = FormValidation.otp(otpCode, length: 6) {
            self.error = APIError(type: .request, message: error)
            return
        }
        
        var modifyRequest = request
        modifyRequest.code = otpCode
        
        /// Network call
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }
            
            do {
                try await verifyResetCodeUseCase.execute(request: modifyRequest)
                AppRouter.shared.navigate(.resetPassword(modifyRequest))
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }
}
