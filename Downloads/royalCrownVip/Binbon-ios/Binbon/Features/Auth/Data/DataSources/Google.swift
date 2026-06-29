//
//  Google.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import UIKit
import GoogleSignIn


extension AuthSelectionView {
    
    func google() {
        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error {
                Console.log("❌ Google", error)
                selectedProvider = nil
                return
            }
            
            guard let user = result?.user else { return }
            
            let token = user.accessToken.tokenString
            viewModel.socialAuth(provider: .google, token: token)
        }
    }
}
