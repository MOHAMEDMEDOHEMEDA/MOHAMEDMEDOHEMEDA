//
//  SocialProviderRow.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct SocialProviderRow: View {
    
    var provider: SocialProvider
    var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            
            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
                .allowsHitTesting(false)

            Spacer()

            Text(provider.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.appText)
                .multilineTextAlignment(.center)

            Spacer()

            Image(provider.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(authListFollowingRowChrome)
        .overlay(authRowBorder)
    }

    private var authListFollowingRowChrome: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(AppColor.chromeButtonGradient)
            .shadow(color: AppColor.authListRowShadowColor, radius: 6, x: 0, y: 3)
    }

    private var authRowBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.appText.opacity(0.12), lineWidth: 1)
    }
}

#Preview {
    SocialProviderRow(provider: .apple, isOn: true)
}
