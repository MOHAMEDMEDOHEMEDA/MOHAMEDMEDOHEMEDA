//
//  EditProfileView.swift
//  Binbon
//

import SwiftUI

struct EditProfileView: View {
    
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    @Environment(\.router) var router
    @State var isShowingDatePicker = false
    @State var isShowingGenderPicker = false
    @State var avatarToDelete: Int?
    
    @StateObject private var viewModel = EditProfileViewModel()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    profilePhotoSection
                        .padding(.top, 24)
                        .padding(.bottom, 32)

                    fieldsSection

                    saveButton
                }
                .adaptiveContentWidth()
            }
            
            if isShowingDatePicker {
                datePickerOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if isShowingGenderPicker {
                genderPickerOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .errorAlert(error: $viewModel.error)
        .onTapDismissKeyboard()
        .appBackground()
        .appNavigation(title: isPresented ? "complete_profile".localized : "edit_profile".localized)
        .onChange(of: viewModel.userDidSave) {
            if viewModel.userDidSave {
                Toaster.shared.show(.success(), "update_successfully".localized)
                if isPresented {
                    isPresented = false
                } else {
                    router.back()
                }
            }
        }
        .deleteAvatarAlert(avatarId: $avatarToDelete) { id in
            viewModel.deleteAvatar(id)
        }
    }
    
    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            ZStack(alignment: .center) {
                ProfileImageField { image in
                    viewModel.uploadAvatar(image)
                }
                .disabled((viewModel.avatarList.count > 6) || (viewModel.uploadAvatarLoading))
                .opacity((viewModel.avatarList.count > 6) || (viewModel.uploadAvatarLoading) ? 0.5 : 1)
                .padding(.horizontal, 16)
                
                ProgressView()
                    .tint(.appText)
                    .opacity(viewModel.uploadAvatarLoading ? 1 : 0)
            }
            
            ScrollView(.horizontal, showsIndicators: true) {
                
                HStack(alignment: .top) {
                    ForEach(0...6, id: \.self) { index in
                        
                        if index < viewModel.avatarList.count {
                            
                            let avatar = viewModel.avatarList[index]
                            
                            ZStack(alignment: .topLeading) {
                                ImageView(avatar.url)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(20)
                                
                                if let id = avatar.id {
                                    Button("delete".localized, systemImage: "trash") {
                                        avatarToDelete = id
                                    }
                                    .font(.footnote.weight(.semibold))
                                    .frame(width: 18, height: 18)
                                    .padding(6)
                                    .tint(.appText)
                                    .background(.red, in: Capsule())
                                    .labelStyle(.iconOnly)
                                    .padding(6)
                                }
                            }
                        } else {
                            Image(systemName: "photo")
                                .foregroundStyle(.appText)
                                .frame(width: 80, height: 80)
                                .background(.appText.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.bottom, 14)
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
    }
    
    // MARK: - Save Button
    var saveButton: some View {
        AppButton(title: "save_changes".localized, isLoading: $viewModel.isLoading, action: viewModel.save)
            .padding(20)
    }
    
    // MARK: - Fields Section
    private var fieldsSection: some View {
        VStack(spacing: 1) {
            ProfileFieldRow(label: "name".localized,     text: $viewModel.fullname)
            ProfileFieldRow(label: "username".localized, text: $viewModel.username)
            ProfileFieldRow(label: "bio".localized,      text: $viewModel.bio)

            ProfileFieldRow(label: "gender".localized, displayValue: viewModel.genderString) {
                dismissKeyboard()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isShowingGenderPicker = true
                }
            }
            
            ProfileFieldRow(label: "date_of_birth".localized, displayValue: $viewModel.dateOfBirth) {
                dismissKeyboard()
                isShowingDatePicker = true
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private enum ProfileFieldType {
        case editable(text: Binding<String>)
        case tappable
    }
    
    private struct ProfileFieldRow: View {
        let label: String
        let type: ProfileFieldType
        let onTap: (() -> Void)?
        
        /// Textfield Init
        init(label: String, text: Binding<String>) {
            self.label = label
            self.type = .editable(text: text)
            self.onTap = nil
            self._displayValue = .constant("")
        }
        
        /// Selection Init
        init(label: String, displayValue: Binding<String>, onTap: @escaping () -> Void) {
            self.label = label
            self.type = .tappable
            self._displayValue = displayValue
            self.onTap = onTap
        }
        
        @Binding private var displayValue: String
        
        var body: some View {
            HStack {
                Text(label)
                    .foregroundColor(.appText.opacity(0.85))
                    .font(.system(size: 15))
                    .frame(width: 110, alignment: .leading)
                
                switch type {
                case .editable(let text):
                    TextField("", text: text)
                        .foregroundColor(.appText)
                        .font(.system(size: 15, weight: .medium))
                        .tint(.appText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    Image(systemName: "pencil")
                        .foregroundColor(.appText.opacity(0.7))
                        .font(.system(size: 14))
                    
                case .tappable:
                    Text(displayValue)
                        .foregroundColor(.appText)
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.appText.opacity(0.7))
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.appText.opacity(0.08))
            .contentShape(Rectangle())
            .onTapGesture {
                if case .tappable = type {
                    onTap?()
                }
            }
        }
    }
    
    // MARK: - Date Picker Overlay
    private var datePickerOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation { isShowingDatePicker = false }
                }
            DatePickerSheet(
                selectedDate: $viewModel.dateOfBirth,
                maxDate: Date(),
                onAccept: {
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
    
    // MARK: - Gender Picker Overlay
    private var genderPickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isShowingGenderPicker = false
                    }
                }
            
            GenderPickerPopup(
                selectedGender: $viewModel.gender,
                onDone: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isShowingGenderPicker = false
                    }
                },
                onCancel: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isShowingGenderPicker = false
                    }
                }
            )
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Gender Picker Popup
private struct GenderPickerPopup: View {
    @Binding var selectedGender: GenderType
    let onDone: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Button("cancel".localized, action: onCancel)
                    .font(.system(size: 15))
                    .foregroundColor(.appText.opacity(0.6))
                
                Spacer()
                
                Text("select_gender".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appText)
                
                Spacer()
                
                Button("done".localized, action: onDone)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "F5A623"))
            }
            
            // Divider
            Rectangle()
                .fill(Color.appText.opacity(0.12))
                .frame(height: 1)
            
            // Gender Selector
            GenderSelector(selectedGender: $selectedGender)
                .padding(.vertical, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.appText.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

#Preview {
    EditProfileView(isPresented: .constant(true))
}


// MARK: - View Modifiers
fileprivate extension View {
    func deleteAvatarAlert(avatarId: Binding<Int?>, onConfirm: @escaping (Int) -> Void) -> some View {
        self.alert(
            "delete_photo_confirmation".localized, isPresented: .init(
                get: { avatarId.wrappedValue != nil },
                set: { if !$0 { avatarId.wrappedValue = nil } } )) {
                    Button("cancel".localized, role: .cancel) {
                        avatarId.wrappedValue = nil
                    }
                    Button("delete".localized, role: .destructive) {
                        if let id = avatarId.wrappedValue {
                            onConfirm(id)
                        }
                        avatarId.wrappedValue = nil
                    }
                } message: {
                    Text("photo_permanently_removed".localized)
                }
    }
}
