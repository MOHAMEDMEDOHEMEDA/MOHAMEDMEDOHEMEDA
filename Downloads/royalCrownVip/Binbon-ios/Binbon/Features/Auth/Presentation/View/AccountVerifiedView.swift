//
//  AccountVerifiedView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct AccountVerifiedView: View {
    
    @Environment(\.router) private var router
    let viewModel: AuthViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Image("alreadyV")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            bottomSection
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.router = router }
        .appBackground()
    }

    private var bottomSection: some View {
        VStack(spacing: 14) {
            Text("account_verified".localized)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("account_successfully_verified".localized)
                .font(.system(size: 14))
                .foregroundStyle(.appText.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            
            AppButton(title: "next".localized, action: { router.navigate(.onboard(.step1Singers)) })
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 180)
    }
}


#Preview {
    AccountVerifiedView(viewModel: AuthViewModel())
        .environment(AuthViewModel())
}
