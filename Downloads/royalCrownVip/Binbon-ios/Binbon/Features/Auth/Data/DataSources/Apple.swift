//
//  Apple.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import UIKit
import AuthenticationServices

// MARK: - View
extension AuthSelectionView {
    
    func apple() {
        let provider = ASAuthorizationAppleIDProvider()
        let request  = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = AppleSignInDelegate.shared
        controller.presentationContextProvider = AppleSignInDelegate.shared
        
        AppleSignInDelegate.shared.onSuccess = { token in
            viewModel.socialAuth(provider: .apple, token: token)
        }
        AppleSignInDelegate.shared.onError = { error in
            Console.log("❌ Apple", error)
            selectedProvider = nil
        }
        
        controller.performRequests()
    }
}

// MARK: - Delegate
final class AppleSignInDelegate: NSObject,
                                 ASAuthorizationControllerDelegate,
                                 ASAuthorizationControllerPresentationContextProviding {
    
    static let shared = AppleSignInDelegate()
    private override init() {}
    
    var onSuccess: ((String) -> Void)?
    var onError:   ((Error) -> Void)?
    
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData  = credential.identityToken,
              let token      = String(data: tokenData, encoding: .utf8) else { return }
        
        onSuccess?(token)
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        
        if (error as? ASAuthorizationError)?.code == .canceled { return }
        onError?(error)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first ?? UIWindow()
    }
}



//                        SignInWithAppleButton(.signIn) { request in
//                            request.requestedScopes = [.fullName, .email]
//                        } onCompletion: { result in
//                            switch result {
//                            case .success(let auth):
//                                break
//                            case .failure(let error):
//                                print(error)
//                            }
//                        }
//                        .frame(height: 50)
//                        .signInWithAppleButtonStyle(.white)
