//
//  ForgetPassView.swift
//  Binbon
//
//  Created by Salah Khaled on 25/04/2026.
//

import SwiftUI

struct ForgetPassView: View {

    // MARK: - Properties
    @Environment(\.router) private var router
    @StateObject private var viewModel = ForgetPassViewModel()
    @State private var isPhonePickerOpen = false

    var body: some View {
        content
            .appBackground()
            .appNavigation(title: "forget_password".localized)
            .errorAlert(errorTitle: "error".localized, error: $viewModel.error)
    }

    private var content: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                Text("forgot_password_subtitle".localized)
                    .font(.subheadline)
                    .foregroundStyle(.appText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)

                methodToggle

                field
                    .zIndex(isPhonePickerOpen ? 100 : 0)

                AppButton(title: "send_code".localized, isLoading: $viewModel.isLoading) {
                    dismissKeyboard()
                    viewModel.onNext()
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(20)
            .adaptiveContentWidth()
        }
    }

    // MARK: - Method toggle (Phone number / E-mail)
    private var methodToggle: some View {
        HStack(alignment: .center,spacing: 28) {
            methodCheckbox(.phone, label: "phone_number".localized)
            methodCheckbox(.email, label: "email".localized)
        }
        .padding(.vertical, 8)
    }

    private func methodCheckbox(_ method: ForgetPassViewModel.RecoveryMethod,
                                label: String) -> some View {
        let selected = viewModel.method == method
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { viewModel.method = method }
        } label: {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(selected ? AnyShapeStyle(AppColor.gold) : AnyShapeStyle(Color.clear))
                    .frame(width: 22, height: 22)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.appText.opacity(selected ? 0 : 0.4), lineWidth: 1.5)
                    }
                    .overlay {
                        if selected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }

                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.appText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }

    // MARK: - Conditional field
    @ViewBuilder
    private var field: some View {
        switch viewModel.method {
        case .phone:
            LabeledField(title: "phone_number".localized, isRequired: true) {
                PhoneFieldWithDropdown(
                    dialCode: $viewModel.dialCode,
                    country: $viewModel.country,
                    phoneNumber: $viewModel.phoneNumber,
                    onCountryPickerVisibilityChange: { isOpen in
                        isPhonePickerOpen = isOpen
                        if isOpen { dismissKeyboard() }
                    }
                )
            }
        case .email:
            AppTextField(title: "email".localized,
                         placeholder: "enter_your_email".localized,
                         isRequired: true,
                         keyboard: .emailAddress,
                         text: $viewModel.email)
        }
    }
}

#Preview {
    NavigationView {
        ForgetPassView()
    }
}
