//
//  AccountSettingView.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import SwiftUI

struct AccountSettingView: View {
    
    @StateObject var viewModel = AccountSettingViewModel()
    @State var isShowingDatePicker = false
    @State var showLogoutAllConfirmation = false
    @State var avatarToDelete: Int?
    @State var deviceToLogout: DeviceSettingModel?
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
                Section("change_username".localized) { usernameSection }
                Section("change_profile_photo".localized, padding: false) { profilePhotoSection }
                Section("edit_bio".localized) { bioSection }
                Section("edit_gender".localized) { genderSection }
                Section("edit_birthday".localized) { birthdaySection }
                Section("edit_phone_number".localized) { phoneSection }
                Section("edit_email_address".localized) { emailSection }
                Section("manage_connected_devices".localized) { deviceSection }
                Section("manage_connected_social_media".localized) { socialSection }
            }
            if isShowingDatePicker {
                datePickerOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: "account_setting".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchProfileSetting() }
        .logoutAllAlert(isPresented: $showLogoutAllConfirmation) {
            viewModel.signOutOthers()
        }
        .logoutDeviceAlert(device: $deviceToLogout) { deviceId in
            viewModel.signOut(deviceId)
        }
        .deleteAvatarAlert(avatarId: $avatarToDelete) { id in
            viewModel.deleteAvatar(id)
        }
    }
    
    private var saveButton: some View {
        Button { viewModel.save() } label: {
            Text("save_changes".localized)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.buttonGradient))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isDataNoChanges())
    }
    
    // MARK: - Sections
    private var usernameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppTextField(placeholder: "enter_your_username".localized,
                         text: $viewModel.username,
                         background: .clear)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("change_username_once_every_30_days".localized)
                    .font(.footnote)
                    .foregroundStyle(.appText)
                
                HStack(spacing: 3) {
                    Text("change_it_before_30_days_you_can_use".localized)
                        .font(.footnote)
                        .foregroundStyle(.appText)
                    
                    Text("paid_features".localized)
                        .font(.footnote.bold())
                        .foregroundStyle(Color.appGold)
                }
            }
            .lineLimit(1)
        }
    }
    
    private var profilePhotoSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Toggle(isOn: $viewModel.profileSliderEnabled) {
                Text("show_all_images_in_profile".localized)
                    .foregroundStyle(.appText)
                    .font(.footnote.weight(.medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            
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
                            
                            VStack(alignment: .center, spacing: 8) {
                                
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
                                
                                Button {
                                    viewModel.avatarId = avatar.id
                                } label: {
                                    Circle()
                                        .fill(viewModel.avatarId == avatar.id ? .green : .clear)
                                        .frame(width: 10, height: 10)
                                        .padding(4)
                                        .overlay {
                                            Capsule().stroke(.appText.opacity(0.2), lineWidth: 1)
                                        }
                                    
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
    
    private var bioSection: some View {
        MultilineTextField(
            text: $viewModel.bio,
            placeholder: "enter_your_bio".localized
        )
    }
    
    private var genderSection: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 20) {
                Button {
                    viewModel.gender = .male
                } label: {
                    Image("Male")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(
                                    viewModel.gender == .male ? .green : .clear,
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: viewModel.gender == .male ? .green.opacity(0.5) : .clear, radius: 6)
                }
                .buttonStyle(.plain)
                
                RadioButton(title: "male".localized, isSelect: viewModel.gender == .male) { viewModel.gender = .male }
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                
                Button {
                    viewModel.gender = .female
                } label: {
                    Image("Female")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(
                                    viewModel.gender == .female ? .green : .clear,
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: viewModel.gender == .female ? .green.opacity(0.5) : .clear, radius: 6)
                }
                .buttonStyle(.plain)
                
                RadioButton(title: "female".localized, isSelect: viewModel.gender == .female) { viewModel.gender = .female }
            }
            
            Spacer()
        }
    }
    
    private var birthdaySection: some View {
        
        Button {
            dismissKeyboard()
            isShowingDatePicker = true
        } label: {
            HStack {
                HStack {
                    Text(viewModel.birthday)
                        .font(.subheadline)
                        .foregroundStyle(.appText)
                    Spacer()
                    Text("edit".localized)
                        .font(.subheadline)
                        .foregroundStyle(.appText.opacity(0.5))
                }
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.clear)
                        .strokeBorder(.appText.opacity(0.2), lineWidth: 1.5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                Text(viewModel.birthday.zodiac())
                    .font(.subheadline)
                    .foregroundStyle(.appText)
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.clear)
                            .strokeBorder(.appText.opacity(0.2), lineWidth: 1.5)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
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
                selectedDate: $viewModel.birthday,
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
    
    private var phoneSection: some View {
        AppTextField(placeholder: "enter_your_phone_number".localized,
                     keyboard: .numberPad,
                     text: $viewModel.phone,
                     background: .clear)
    }
    
    private var emailSection: some View {
        AppTextField(placeholder: "enter_your_email".localized,
                     keyboard: .emailAddress,
                     text: $viewModel.email,
                     background: .clear)
    }
    
    private var deviceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            VStack(alignment: .leading, spacing: 0) {
                Text("devices_status".localized)
                    .font(.subheadline.weight(.bold))
                Text("click_on_device_to_logout".localized)
                    .font(.footnote)
                    .opacity(0.7)
            }
            .foregroundStyle(.appText)
            
            AppButton(title: "sign_out_of_other_devices".localized,
                      isLoading: $viewModel.logoutAllLoading) {
                showLogoutAllConfirmation = true
            }
            
            ForEach(viewModel.deviceList, id: \.id) { device in
                Button {
                    if device.isActive == false { deviceToLogout = device }
                } label: {
                    ZStack(alignment: .center) {
                        if viewModel.deviceLoading[device.id ?? 0] == true {
                            ProgressView()
                                .tint(.appText)
                        }
                        
                        HStack(spacing: 12) {
                            Image(device.deviceType ?? "device")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(device.deviceName ?? "")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.appText)
                                
                                Text(device.isActive == true ? "active_now".localized : "last_active_at".localizedFormat(device.lastLoginAt ?? ""))
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(device.isActive == true ? .green : .appText.opacity(0.7))
                            }
                            Spacer()
                        }
                        .opacity(viewModel.deviceLoading[device.id ?? 0] == true ? 0 : 1)
                    }
                    .padding()
                    .background(.appText.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var socialSection: some View {
        
        let platformIconMap: [(platform: String, icon: String)] = [
            ("instagram", "profile-instagram"),
            ("thread",    "profile-thread"),
            ("facebook",  "profile-facebook"),
            ("x",         "profile-x"),
            ("youtube",   "profile-youtube"),
            ("tiktok",    "profile-tiktok"),
            ("snapchat",  "profile-snapchat"),
            ("whatsapp",  "profile-whatsapp")
        ]
        
        return VStack(alignment: .leading, spacing: 12) {
            ForEach(platformIconMap, id: \.icon) { item in
                
                let isLinked = viewModel.isLinked(platform: item.platform)
                let isLoading = viewModel.socialLinkLoading[item.platform] ?? false
                
                HStack {
                    Image(item.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .padding(8)
                        .background(.appSurface, in: Capsule())

                    Image(systemName: "link")
                        .foregroundStyle(isLinked ? .green : .appText)
                    
                    TextField("URL", text: Binding(
                        get: { viewModel.socialURLs[item.platform] ?? "" },
                        set: { viewModel.socialURLs[item.platform] = $0 }
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.appText)
                    .padding(14)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.clear)
                            .strokeBorder(.appText.opacity(0.2), lineWidth: 1.5)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .disabled(isLinked)
                    .simultaneousGesture(TapGesture())
                    
                    Button {
                        if isLinked {
                            viewModel.unlinkSocial(platform: item.platform)
                        } else {
                            viewModel.linkSocial(platform: item.platform)
                        }
                    } label: {
                        ZStack {
                            Text(isLinked ? "unlink".localized : "link".localized)
                                .font(.callout.bold())
                                .foregroundStyle(.appText)
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .tint(.appText)
                            }
                        }
                        .frame(maxWidth: 70)
                        .padding(.vertical, 10)
                        .disabled(isLoading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AnyShapeStyle(AppColor.authListFollowingRowGradient))
                                .shadow(
                                    color: AppColor.authListRowShadowColor,
                                    radius: 6,
                                    x: 0,
                                    y: 3
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appText.opacity(0.3), lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Toggle(isOn: $viewModel.hideSocialLinks) {
                Text("hide_all_social_media_links".localized)
                    .foregroundStyle(.appText)
                    .font(.footnote.weight(.medium))
            }
            .padding(.top, 12)
            .padding(.bottom, 6)
        }
    }
}

// MARK: - View Modifiers
fileprivate extension View {
    func logoutAllAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.alert(
            "sign_out_of_other_devices_confirmation".localized,
            isPresented: isPresented
        ) {
            Button("cancel".localized, role: .cancel) {}
            Button("sign_out".localized, role: .destructive) {
                onConfirm()
            }
        } message: {
            Text("signed_out_from_all_other_devices".localized)
        }
    }
    
    func logoutDeviceAlert(
        device: Binding<DeviceSettingModel?>,
        onConfirm: @escaping (Int) -> Void
    ) -> some View {
        self.alert(
            "sign_out_of_this_device_confirmation".localized,
            isPresented: .init(
                get: { device.wrappedValue != nil },
                set: { if !$0 { device.wrappedValue = nil } }
            )
        ) {
            Button("cancel".localized, role: .cancel) {
                device.wrappedValue = nil
            }
            Button("sign_out".localized, role: .destructive) {
                if let id = device.wrappedValue?.id {
                    onConfirm(id)
                }
                device.wrappedValue = nil
            }
        } message: {
            if let deviceModel = device.wrappedValue {
                Text("sign_out_from_device".localizedFormat(deviceModel.deviceName ?? "this device"))
            }
        }
    }
    
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

#Preview {
    NavigationView {
        AccountSettingView()
    }
}
