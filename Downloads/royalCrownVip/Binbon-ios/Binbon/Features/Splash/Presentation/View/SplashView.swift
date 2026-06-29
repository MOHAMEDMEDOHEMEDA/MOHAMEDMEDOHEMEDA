//
//  SplashView.swift
//  Binbon
//
//  Created by Salah Khaled on 18/05/2026.
//

import SwiftUI

struct SplashView: View {

    /// Duration of the logo entrance animation before the hold begins.
    private let entranceDuration: Double = 0.8
    /// How long the fully-revealed logo stays on screen before navigating.
    private let holdDuration: Double = 4.0

    /// Called once the logo has appeared and the hold has elapsed.
    var onFinished: () -> Void = {}

    @State private var isAnimating = false
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App Logo
            Image(Storage.shared.didLaunch ? "binbon-logo" : "royal-crown-logo")
                .resizable()
                .frame(width: 160, height: 160)
                .scaledToFit()
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(opacity)
            
            if Storage.shared.didLaunch == false {
                Text("by_royal_crown_vip".localized)
                    .font(.title.bold())
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "EAD28A"), Color(hex: "976E36")], startPoint: .top, endPoint: .bottom))
                    .shadow(color: .black.opacity(0.5), radius: 4)
            }
            
            Spacer()
            
            // Loading indicator
            ProgressView()
                .tint(.appText)
                .scaleEffect(1.2)
                .opacity(opacity * 0.7)
                .padding(.bottom, 50)
        }
        .appBackground()
        .onAppear {
            withAnimation(.spring(response: entranceDuration, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }

            // Once the logo has appeared, hold for two seconds before navigating.
            DispatchQueue.main.asyncAfter(deadline: .now() + entranceDuration + holdDuration) {
                onFinished()
            }
        }
        .onDisappear { Storage.shared.didLaunch = true }
    }
}

#Preview {
    SplashView()
}
