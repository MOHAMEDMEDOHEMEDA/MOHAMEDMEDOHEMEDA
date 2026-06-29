//
//  VerifyOTPView.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import SwiftUI

struct VerifyOTPView: View {
    
    // MARK: - Properties
    @Environment(\.router) private var router
    @StateObject private var viewModel = VerifyOTPViewModel()
    
    let request: PasswordRequest
    
    var body: some View {
        content
            .appBackground()
            .appNavigation(title: "verify_otp".localized)
            .errorAlert(errorTitle: "error".localized, error: $viewModel.error)
            .onAppear {
                if viewModel.secondsRemaining == 0 { viewModel.startResendTimer() }
            }
    }
    
    var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                AppMessage("enter_otp_code".localized)

                OTPInputView(code: $viewModel.otpCode)

                AppButton(title: "next".localized, isLoading: $viewModel.isLoading) {
                    dismissKeyboard()
                    viewModel.onNext(request)
                }

                resendSection
                    .padding(.top, 12)

                Spacer()
            }
            .padding(20)
            .adaptiveContentWidth()
        }
    }

    // MARK: - Resend
    private var resendSection: some View {
        HStack(spacing: 4) {
            Text("didnt_receive_code".localized)
                .foregroundStyle(.appText)

            if viewModel.secondsRemaining > 0 {
                // Countdown until resend is allowed.
                Text(timeString(viewModel.secondsRemaining))
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(AppColor.gold)
            } else {
                Button {
                    dismissKeyboard()
                    viewModel.resend(request)
                } label: {
                    Text("resend".localized)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColor.gold)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isResending)
            }
        }
        .font(.system(size: 14, weight: .medium))
        .frame(maxWidth: .infinity)
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    NavigationView {
        ForgetPassView()
    }
}
