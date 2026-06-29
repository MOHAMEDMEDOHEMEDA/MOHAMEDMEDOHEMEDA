//
//  AuthSelectionView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI
import UIKit
import AuthenticationServices

struct AuthSelectionView: View {
    
    @State var viewModel = AuthViewModel()
    @Environment(\.router) var router

    @State var selectedProvider: SocialProvider?
    @State private var showTest = false

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 12) {
                    characterSection
                    providersList
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .adaptiveContentWidth()
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .appBackground()
        .onAppear {
            viewModel.router = router
            selectedProvider = nil
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        .appNavigation(title: "authentication".localized)
        /// Test
        .sheetView(isPresented: $showTest, detents: [.medium, .large]) {
            FilterKeywordsView()
        }
    }

    private var characterSection: some View {
        Image("Reg_Avatar")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 300)
            .padding(.top, 40)
            .padding(.bottom, -20)
    }

    private var providersList: some View {
        
        return ForEach(SocialProvider.allCases, id: \.id) { provider in
            
            SocialProviderRow(provider: provider, isOn: selectedProvider == provider)
                .onTapGesture {
                    selectedProvider = provider
                    
                    switch provider {
                    case .accountVerification: router.navigate(.verification)
                    case .google:    google()
                    case .apple:     apple()
                    case .tikTok:    break
                    case .instagram: break
                    case .x:         break
                    case .facebook:  break
                    case .snapchat:  break
                    case .threads:   break
                    }
                }
        }
        
    }

    private var actionButtons: some View {
        
        VStack(spacing: 12) {

            AppButton(title: "login".localized) { router.navigate(.login) }
            AppButton(title: "create_account".localized) { router.navigate(.createAccount) }
          
        }
        .padding(.top, 10)
    }
}

#Preview {
    AuthSelectionView()
}
