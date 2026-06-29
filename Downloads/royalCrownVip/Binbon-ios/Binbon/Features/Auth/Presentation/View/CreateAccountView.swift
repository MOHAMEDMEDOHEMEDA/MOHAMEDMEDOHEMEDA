//
//  CreateAccountView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct CreateAccountView: View {
    
    @State private var viewModel = AuthViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.router) private var router
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var dialCode = "+20"
    @State private var country = Country.default
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var hasAgreedToTerms = false
    @State private var isPhoneCountryPickerOpen = false
    @State private var validationMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                AppTextField(title: "email".localized,
                             placeholder: "enter_your_email".localized,
                             isRequired: true,
                             keyboard: .emailAddress,
                             text: $email)

                LabeledField(title: "phone_number".localized, isRequired: true) {
                    PhoneFieldWithDropdown(
                        dialCode: $dialCode,
                        country: $country,
                        phoneNumber: $phoneNumber,
                        onCountryPickerVisibilityChange: { isOpen in
                            isPhoneCountryPickerOpen = isOpen
                            if isOpen { dismissKeyboard() }
                        }
                    )
                }
                .zIndex(isPhoneCountryPickerOpen ? 100 : 0)
                
                AppTextField(title: "password".localized,
                             placeholder: "enter_your_password".localized,
                             isRequired: true,
                             isPassword: true,
                             text: $password)

                AppTextField(title: "confirm_password".localized,
                             placeholder: "enter_your_password".localized,
                             isRequired: true,
                             isPassword: true,
                             text: $confirmPassword)
                
                termsRow
                
                VStack(spacing: 10) {
                    
                    AppButton(title: "next".localized, action: handleNext)
                    
                    HStack {
                        Spacer()
                        if let validationMessage {
                            Text(validationMessage)
                                .font(.system(size: 13))
                                .foregroundStyle(Color(hex: "FF6B6B"))
                        }
                        Spacer()
                    }
                }
                .padding(.top, 8)
            }
            .padding(20)
            .adaptiveContentWidth()
        }
        .appBackground()
        .loadingOverlay(viewModel.isLoading)
        .appNavigation(title: "create_new_account".localized)
        .onChange(of: email) { _, _ in validationMessage = nil }
        .onChange(of: phoneNumber) { _, _ in validationMessage = nil }
        .onChange(of: password) { _, _ in validationMessage = nil }
        .onChange(of: confirmPassword) { _, _ in validationMessage = nil }
        .onChange(of: hasAgreedToTerms) { _, _ in validationMessage = nil }
        .onAppear { viewModel.router = router }
    }

    private var termsRow: some View {
        
        Button {
            hasAgreedToTerms.toggle()
        } label: {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: hasAgreedToTerms ? "checkmark.square.fill" : "square")
                    .foregroundStyle(hasAgreedToTerms ? Color(hex: "E97840") : .appText.opacity(0.7))
                    .font(.system(size: 18))
                    .frame(width: 20, height: 20, alignment: .leading)
                
                Text("agree_to_terms_privacy".localized)
                    .font(.system(size: 12))
                    .foregroundStyle(.appText.opacity(0.85))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        
    }

    private func handleNext() {
        if let err = FormValidation.email(email) {
            validationMessage = err
            return
        }
        if let err = FormValidation.phoneDigits(phoneNumber) {
            validationMessage = err
            return
        }
        if let err = FormValidation.password(password) {
            validationMessage = err
            return
        }
        if let err = FormValidation.confirmPassword(password, confirmPassword) {
            validationMessage = err
            return
        }
        if let err = FormValidation.terms(hasAgreedToTerms) {
            validationMessage = err
            return
        }
        validationMessage = nil
        viewModel.registerData.email = email
        viewModel.registerData.phoneNumber = phoneNumber
        viewModel.registerData.dialCode = dialCode
        viewModel.registerData.countryKey = country.key
        viewModel.registerData.password = password
        viewModel.registerData.confirmPassword = confirmPassword
        viewModel.registerData.hasAgreedToTerms = hasAgreedToTerms
        
        router.navigate(.profileSetup(viewModel))
    }
}

#Preview {
    NavigationView {
        CreateAccountView()
    }
}
