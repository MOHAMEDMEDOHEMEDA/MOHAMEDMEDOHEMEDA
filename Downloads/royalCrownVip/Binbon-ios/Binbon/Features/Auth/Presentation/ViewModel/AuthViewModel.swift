//
//  AuthViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//
//  Presentation layer — drives the authentication screens. Holds no networking:
//  business operations run through injected use cases; navigation goes through the
//  `AppRouter` (`Route`) set by the view.
//

import SwiftUI
import Observation

// MARK: - State

/// The current status of the screen's async work. Source of truth for the loading
/// and error projections the views bind to.
enum AuthState {
    case idle
    case loading
    case success
    case failed(APIError)
}

@MainActor
@Observable
final class AuthViewModel: Equatable, Hashable {

    // MARK: - Navigation
    var router: AppRouter?

    // MARK: - Input
    var registerData = RegistrationData()

    // MARK: - State
    var state: AuthState = .idle

    /// Loading projection kept for the views that bind to `isLoading`.
    var isLoading: Bool {
        get { if case .loading = state { return true }; return false }
        set { state = newValue ? .loading : .idle }
    }

    /// Error projection kept for the views that bind to / clear `error`.
    var error: APIError? {
        get { if case .failed(let error) = state { return error }; return nil }
        set {
            if let newValue {
                state = .failed(newValue)
            } else if case .failed = state {
                state = .idle
            }
        }
    }

    // MARK: - Use cases
    private let loginUseCase: LoginUseCase
    private let registerUseCase: RegisterUseCase
    private let sendOtpUseCase: SendOtpUseCase
    private let verifyOtpUseCase: VerifyOtpUseCase
    private let socialLoginUseCase: SocialLoginUseCase
    private let biometric = BiometricAuthManager()

    // MARK: - Init
    init(
        loginUseCase: LoginUseCase,
        registerUseCase: RegisterUseCase,
        sendOtpUseCase: SendOtpUseCase,
        verifyOtpUseCase: VerifyOtpUseCase,
        socialLoginUseCase: SocialLoginUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.registerUseCase = registerUseCase
        self.sendOtpUseCase = sendOtpUseCase
        self.verifyOtpUseCase = verifyOtpUseCase
        self.socialLoginUseCase = socialLoginUseCase
    }

    /// Convenience entry point used by the views — resolves the full use-case graph
    /// through the composition root.
    convenience init(container: AppDIContainer = .shared) {
        self.init(
            loginUseCase: container.makeLoginUseCase(),
            registerUseCase: container.makeRegisterUseCase(),
            sendOtpUseCase: container.makeSendOtpUseCase(),
            verifyOtpUseCase: container.makeVerifyOtpUseCase(),
            socialLoginUseCase: container.makeSocialLoginUseCase()
        )
    }

    // MARK: - Registration
    func proceedToEmailVerification() {
        Task {
            state = .loading
            do {
                _ = try await registerUseCase.execute(request: RegisterUserRequest(from: registerData))
                state = .success
                router?.navigate(.emailVerification(self))
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String) {
        if let err = FormValidation.email(email) {
            state = .failed(APIError(type: .request, message: err))
            return
        }
        if let err = FormValidation.password(password) {
            state = .failed(APIError(type: .request, message: err))
            return
        }

        let request = LoginUserRequest(email: email,
                                       password: password,
                                       deviceType: DeviceUtility.deviceName,
                                       operatingSystem: "\(DeviceUtility.deviceGeneration ?? 0)")

        Task {
            state = .loading
            do {
                _ = try await loginUseCase.execute(request: request)
                state = .success

                if Storage.shared.user?.onboardingRequired == true,
                   Storage.shared.user?.onboardingCompleted == false {
                    router?.root(.onboard(.step1Singers))
                } else {
                    router?.root(.home)
                }
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    // MARK: - Biometric login

    /// Whether the device exposes Face ID / Touch ID hardware.
    var hasBiometricHardware: Bool { biometric.hasHardware }

    /// Confirms the device owner with Face ID / Touch ID, then submits the entered
    /// credentials. Silent failures (user cancel) are ignored.
    func loginWithBiometrics(email: String, password: String) {
        Task {
            let result = await biometric.authenticate(reason: "login_with_biometry".localized)
            switch result {
            case .success:
                login(email: email, password: password)
            case .failure(let err):
                if !err.isSilent {
                    state = .failed(APIError(type: .request, message: err.messageKey.localized))
                }
            }
        }
    }

    // MARK: - OTP
    func sendOTP() {
        Task {
            state = .loading
            do {
                try await sendOtpUseCase.execute(email: registerData.email)
                state = .idle
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    func verifyOTP(_ otp: String) {
        Task {
            state = .loading
            do {
                try await verifyOtpUseCase.execute(email: registerData.email, otp: otp)
                state = .success
                router?.navigate(.accountVerified(self))
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    // MARK: - Social
    func socialAuth(provider: SocialProvider, token: String) {
        Task {
            state = .loading
            do {
                _ = try await socialLoginUseCase.execute(provider: provider, token: token)
                state = .success
                router?.root(.home)
            } catch {
                let apiError = asAPIError(error)
                state = .idle
                Toaster.shared.show(.error("person.circle"), apiError.message ?? "Something went wrong!", 4)
            }
        }
    }

    // MARK: - Helpers
    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}

// MARK: - Hashable
extension AuthViewModel {
    nonisolated static func == (lhs: AuthViewModel, rhs: AuthViewModel) -> Bool {
        lhs === rhs
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
