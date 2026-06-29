//
//  ResetPassView.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import SwiftUI

struct ResetPassView: View {
    
    // MARK: - Properties
    @Environment(\.router) private var router
    @StateObject private var viewModel = ResetPassViewModel()
    
    let request: PasswordRequest
    
    var body: some View {
        content
            .appBackground()
            .appNavigation(title: "reset_password".localized)
            .errorAlert(errorTitle: "error".localized, error: $viewModel.error)
    }
    
    var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                AppMessage("enter_new_password_confirm".localized)

                AppTextField(title: "password".localized,
                             placeholder: "enter_your_password".localized,
                             isRequired: true,
                             isPassword: true,
                             text: $viewModel.password)

                AppTextField(title: "confirm_password".localized,
                             placeholder: "enter_your_confirm_password".localized,
                             isRequired: true,
                             isPassword: true,
                             text: $viewModel.passwordConfirm)

                AppButton(title: "reset_password".localized, isLoading: $viewModel.isLoading) {
                    dismissKeyboard()
                    viewModel.onConfirm(request)
                }

                Spacer()
            }
            .padding(20)
            .adaptiveContentWidth()
        }
    }
}

#Preview {
    NavigationView {
        ForgetPassView()
    }
}
