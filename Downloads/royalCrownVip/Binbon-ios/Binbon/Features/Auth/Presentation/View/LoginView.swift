//
//  LoginView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct LoginView: View {

    @Environment(\.router) private var router
    @State private var viewModel = AuthViewModel()

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                hero
                form
            }
            .adaptiveContentWidth()
        }
        .appBackground()
        .loadingOverlay(viewModel.isLoading)
        .appNavigation(title: "account_login".localized)
        .onAppear {
            viewModel.router = router

            #warning("Remove")
            #if DEBUG
            email = "mrwan@gmail.com"
            password = "secret123"
            #endif
        }
        .onChange(of: email) { viewModel.error = nil }
        .onChange(of: password) { viewModel.error = nil }
    }

    // MARK: - Hero
    private var hero: some View {
        Image("login-hero")
            .resizable()
            .scaledToFill()
            .frame(height: 350)
            .frame(maxWidth: .infinity)
            .clipped()
    }

    // MARK: - Form
    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {

            AppTextField(title: "email".localized,
                         placeholder: "enter_your_email".localized,
                         isRequired: true,
                         keyboard: .emailAddress,
                         text: $email)

            AppTextField(title: "password".localized,
                         placeholder: "enter_your_password".localized,
                         isRequired: true,
                         isPassword: true,
                         text: $password)

            rememberRow

            if let error = viewModel.error {
                Text(error.message ?? "")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "FF6B6B"))
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            buttonsRow
                .padding(.top, 8)

            biometricButton
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            signUpRow
                .padding(.top, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppColor.appBarFill,
            in: UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24,
                style: .continuous
            )
        )
  
    }

    // MARK: - Remember me / Forgot password
    private var rememberRow: some View {
        HStack {
            Button {
                rememberMe.toggle()
            } label: {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.appText.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                        .overlay {
                            if rememberMe {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(AppColor.gold)
                            }
                        }

                    Text("remember_me".localized)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.appText)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                router.navigate(.forgetPassword)
            } label: {
                Text("forgot_password".localized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.gold)
                    .underline()
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Biometric login (circular icon + label)
    private var biometricButton: some View {
        Button {
            dismissKeyboard()
            viewModel.loginWithBiometrics(email: email, password: password)
        } label: {
            VStack(spacing: 8) {
                Image("ic-biometry")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)

                Text("login_with_biometry".localized)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(AppColor.gold)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("login_with_biometry".localized)
    }

    // MARK: - Buttons (Log in + Biometry, side by side)
    private var buttonsRow: some View {
        HStack(spacing: 12) {
            AppButton(title: "login".localized,
                      isLoading: .constant(viewModel.isLoading)) {
                viewModel.login(email: email, password: password)
            }

           
        }
    }

    // MARK: - Sign up
    private var signUpRow: some View {
        HStack(spacing: 4) {
            Spacer()
            Text("dont_have_account".localized)
                .foregroundStyle(.appText)

            Button {
                router.navigate(.createAccount)
            } label: {
                Text("sign_up".localized)
                    .foregroundStyle(AppColor.gold)
                    .underline()
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .font(.system(size: 14, weight: .medium))
    }
}

#Preview {
    LoginView()
}
