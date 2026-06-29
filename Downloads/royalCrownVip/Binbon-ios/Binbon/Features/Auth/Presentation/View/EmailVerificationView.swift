//
//  EmailVerificationView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct EmailVerificationView: View {
    
    @State var viewModel: AuthViewModel
    
    @Environment(\.router) private var router
    @State private var otpCode = ""
    @State private var validationMessage: String?
    
    @State private var timeRemaining = 60
    @State private var canResend = false
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            Image("pinCodeScreen")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
            
            
            VStack(spacing: 50) {
                
                titleSection
                
                OTPInputView(code: $otpCode)
                
                if let validationMessage {
                    Text(validationMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "FF6B6B"))
                }
                
                 resendRow
                
                AppButton(title: "verify".localized, isLoading: $viewModel.isLoading, action: handleVerify)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .offset(y: -10)
        }
        .appBackground()
        .appNavigation()
        .errorAlert(error: $viewModel.error)
        .onChange(of: otpCode) { _, _ in validationMessage = nil }
        .onAppear {
            viewModel.router = router
            viewModel.sendOTP()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var titleSection: some View {
        VStack(spacing: 10) {
            Text("check_your_email".localized)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("code_sent_to_email".localizedFormat(viewModel.registerData.email))
                .font(.system(size: 14))
                .foregroundStyle(.appText.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    private var resendRow: some View {
        
        HStack(spacing: 4) {
            Text("didnt_receive_code".localized)
                .font(.system(size: 13))
                .foregroundStyle(.appText.opacity(0.85))

            if canResend {
                Button(action: handleResend) {
                    Text("resend".localized)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.yellow)
                        .underline(true, color: Color(hex: "FFB347"))
                }
                .buttonStyle(.plain)
            } else {
                Text("resend_in_seconds".localizedFormat(timeRemaining))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.appText.opacity(0.5))
            }
        }
    }

    private func handleVerify() {
        if let error = FormValidation.otp(otpCode) {
            validationMessage = error
            return
        }
        
        validationMessage = nil
        viewModel.verifyOTP(otpCode)
    }
    
    private func startTimer() {
        timeRemaining = 60
        canResend = false
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                canResend = true
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleResend() {
        viewModel.sendOTP()
        startTimer()
    }
}


#Preview {
    EmailVerificationView(viewModel: AuthViewModel())
        .environment(AuthViewModel())
}
