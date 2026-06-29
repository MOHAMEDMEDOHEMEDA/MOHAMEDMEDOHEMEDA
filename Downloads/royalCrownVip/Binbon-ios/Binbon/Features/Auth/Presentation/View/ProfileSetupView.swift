//
//  ProfileSetupView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct ProfileSetupView: View {
    
    let viewModel: AuthViewModel
    
    @Environment(\.router) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var fullName = ""
    @State private var dateOfBirth = ""
    @State private var gender: GenderType = .male
    @State private var isShowingDatePicker = false
    @State private var tempDate = ""
    @State private var validationMessage: String?

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    avatarSection
                    
                    AppTextField(title: "username".localized,
                                 placeholder: "enter_your_username".localized,
                                 isRequired: true,
                                 text: $username)


                    AppTextField(title: "name".localized,
                                 placeholder: "enter_your_name".localized,
                                 isRequired: true,
                                 text: $fullName)
                    
                    dateOfBirthButton
                    genderSection

                    if let validationMessage {
                        Text(validationMessage)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "FF6B6B"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                    } else if let error = viewModel.error {
                        Text(error.message ?? "")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: "FF6B6B"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                    }

                    AppButton(
                        title: viewModel.isLoading ? "creating_account".localized : "next".localized,
                        isDisabled: viewModel.isLoading,
                        action: handleNext
                    )
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
                .adaptiveContentWidth()
            }
            if isShowingDatePicker {
                datePickerOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .appBackground()
        .appNavigation()
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isShowingDatePicker)
        .onChange(of: username) { _, _ in validationMessage = nil }
        .onChange(of: fullName) { _, _ in validationMessage = nil }
        .onChange(of: dateOfBirth) { _, _ in validationMessage = nil }
        .onAppear { viewModel.router = router }
    }

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .frame(width: 135, height: 135)
                    .overlay(
                        Image("Profile")
                            .resizable()
                            .scaledToFill()
//                            .frame(width: 55, height: 55)
                            .foregroundStyle(.appText)
                    )
            }
            Text("share_photo_find_friends".localized)
                .font(.system(size: 13))
                .foregroundStyle(.appText.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }

    private var dateOfBirthButton: some View {
        
        
        VStack(alignment: .leading) {
            HStack(spacing: 1) {
                Text("birthday".localized)
                    .foregroundStyle(.appText)
                Text("*")
                    .foregroundStyle(.red)
            }
            .font(.subheadline)
            
            Button(action: {
                tempDate = dateOfBirth
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isShowingDatePicker = true
                }
            }) {
                HStack {
                    Text(dateOfBirth)
                        .font(.system(size: 15))
                        .foregroundStyle(Color(white: 0.15))
                    Spacer()
                    if !zodiacSign.isEmpty {
                        Text(zodiacSign)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(white: 0.4))
                    }
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
        
        
    }

    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("select_your_gender".localized)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.appText)
            GenderSelector(selectedGender: $gender)
        }
    }

    private var datePickerOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isShowingDatePicker = false }
                }
            DatePickerSheet(
                selectedDate: $tempDate,
                maxDate: Date(),
                onAccept: {
                    dateOfBirth = tempDate
                    withAnimation { isShowingDatePicker = false }
                },
                onCancel: {
                    withAnimation { isShowingDatePicker = false }
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }

    private var zodiacSign: String {
        dateOfBirth.zodiac()
    }

    private func handleNext() {
        if let err = FormValidation.username(username) {
            validationMessage = err
            return
        }
        if let err = FormValidation.fullName(fullName) {
            validationMessage = err
            return
        }
        if let err = FormValidation.dateOfBirth(dateOfBirth) {
            validationMessage = err
            return
        }
        validationMessage = nil
        viewModel.registerData.username = username
        viewModel.registerData.fullName = fullName
        viewModel.registerData.dateOfBirth = dateOfBirth
        viewModel.registerData.gender = gender
        viewModel.proceedToEmailVerification()
    }
}


#Preview {
    ProfileSetupView(viewModel: AuthViewModel())
        .environment(AuthViewModel())
}
