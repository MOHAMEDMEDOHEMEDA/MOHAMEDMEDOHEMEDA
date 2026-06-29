//
//  Step1PersonalInfoView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

struct Step1PersonalInfoView: View {
    
    @ObservedObject var viewModel: VerificationViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Full name
                        
                        AppTextField(title: "full_name".localized,
                                     placeholder: "enter_your_name".localized,
                                     text: $viewModel.fullName)
                        
                        AppTextField(title: "id_number".localized,
                                     placeholder: "enter_id_number".localized,
                                     keyboard: .numberPad,
                                     limit: 14,
                                     text: $viewModel.idNumber)
                        
                        AppTextField(title: "address".localized,
                                     placeholder: "enter_your_address".localized,
                                     text: $viewModel.address)
                        
                        LabeledField(title: "date_of_birth".localized) {
                            dateOfBirthButton
                        }
                        
                        LabeledField(title: "phone_number".localized, isRequired: true) {
                            PhoneFieldWithDropdown(
                                dialCode: $viewModel.dialCode,
                                country: $viewModel.country,
                                phoneNumber: $viewModel.phoneNumber,
                                onCountryPickerVisibilityChange: { isOpen in
                                    if isOpen { dismissKeyboard() }
                                    viewModel.isPhoneCountryPickerOpen = isOpen
                                }
                            )
                        }
                        .zIndex(viewModel.isPhoneCountryPickerOpen ? 100 : 0)
                        
                        AppTextField(title: "city".localized,
                                     placeholder: "enter_your_city".localized,
                                     text: $viewModel.city)
                        
                        AppTextField(title: "village".localized,
                                     placeholder: "enter_your_village".localized,
                                     text: $viewModel.village)
                        
                        AppTextField(title: "whatsapp_user".localized,
                                     placeholder: "enter_whatsapp_user".localized,
                                     text: $viewModel.whatsApp)
                        
                        AppTextField(title: "state".localized,
                                     placeholder: "enter_your_state".localized,
                                     text: $viewModel.state)
                        
                        
                        // Account type
                        HStack(spacing: 40) {
                            AccountTypeButton(
                                label: "personal_account".localized,
                                isSelected: viewModel.accountType == .personal,
                                action: { viewModel.accountType = .personal }
                            )
                            AccountTypeButton(
                                label: "company_account".localized,
                                isSelected: viewModel.accountType == .company,
                                action: { viewModel.accountType = .company }
                            )
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
            if viewModel.isShowingDatePicker {
                datePickerOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .errorAlert(error: $viewModel.error)
    }
    
    private var dateOfBirthButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                viewModel.isShowingDatePicker = true
            }
        }) {
            HStack {
                Text(viewModel.dateOfBirth)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(white: 0.15))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color.appText.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var datePickerOverlay: some View {
        DatePickerSheet(
            selectedDate: $viewModel.dateOfBirth,
            maxDate: Date(),
            onAccept: {
                withAnimation { viewModel.isShowingDatePicker = false }
            },
            onCancel: {
                withAnimation { viewModel.isShowingDatePicker = false }
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }
}

private struct AccountTypeButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appText)
                ZStack {
                    Circle()
                        .stroke(Color.appText.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.45, blue: 0.2))
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
    }
}
