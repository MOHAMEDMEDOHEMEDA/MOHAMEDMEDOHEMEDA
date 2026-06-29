//
//  VerificationSuccessView.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import SwiftUI

struct VerificationSuccessView: View {
    
    let status: Bool?
    let message: String?
    @Environment(\.router) private var router

    var body: some View {
        content
            .appBackground()
            .appNavigation(title: "account_verification".localized)
            .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Content
    private var content: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            Image(.regVerify)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
            
            Text((status ?? true) ? "success".localized : "failed".localized)
                .font(.title2.bold())
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.top, 20)
            
            Text(message ?? "verification_submitted_72h".localized)
                .font(.callout)
                .foregroundColor(.appText.opacity(0.75))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .padding(.bottom, 24)
                .multilineTextAlignment(.center)
                
            
            Spacer()
            
            AppButton(title: "home".localized) {
                router.root(.home)
            }
        }
        .padding(.horizontal, 20)
        .adaptiveContentWidth()
    }
}

#Preview {
    VerificationSuccessView(status: true, message: "Success message")
}
