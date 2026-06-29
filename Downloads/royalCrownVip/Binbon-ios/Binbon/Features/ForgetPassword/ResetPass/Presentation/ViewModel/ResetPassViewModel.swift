//
//  ResetPassViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import Foundation
import Combine

@MainActor
class ResetPassViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var error: APIError?
    @Published var isLoading: Bool = false
    @Published var password = ""
    @Published var passwordConfirm = ""
    
    var request = PasswordRequest()
    private let resetPasswordUseCase: ResetPasswordUseCase
    // TODO: cross-feature dependency on Auth's LoginUseCase — extract a shared
    // session/sign-in use case into Interfaces/ so this feature no longer reaches
    // into Auth to auto-login after a reset.
    private let loginUseCase: LoginUseCase

    init(
        resetPasswordUseCase: ResetPasswordUseCase,
        loginUseCase: LoginUseCase
    ) {
        self.resetPasswordUseCase = resetPasswordUseCase
        self.loginUseCase = loginUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            resetPasswordUseCase: container.makeResetPasswordUseCase(),
            loginUseCase: container.makeLoginUseCase()
        )
    }

    // MARK: - Method
    func onConfirm(_ request: PasswordRequest) {
        
        if let error = FormValidation.password(password) {
            self.error = APIError(type: .request, message: error)
            return
        }
        
        if let error = FormValidation.confirmPassword(password, passwordConfirm) {
            self.error = APIError(type: .request, message: error)
            return
        }
        
        var modifyRequest = request
        modifyRequest.password = password
        modifyRequest.passwordConfirm = passwordConfirm
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await resetPasswordUseCase.execute(request: modifyRequest)
                Toaster.shared.show(.success("staroflife.circle"), "password_reset_successfully".localized)
                login(email: modifyRequest.email ?? "", password: modifyRequest.password ?? "")
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
        
    }
    
    func login(email: String, password: String) {
        
        let request = LoginUserRequest(email: email,
                                       password: password,
                                       deviceType: DeviceUtility.deviceName,
                                       operatingSystem: "\(DeviceUtility.deviceGeneration ?? 0)")
        
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                _ = try await loginUseCase.execute(request: request)
                AppRouter.shared.root(.home)
            } catch {
                AppRouter.shared.navigate(.authSelection)
            }
        }
    }
}
