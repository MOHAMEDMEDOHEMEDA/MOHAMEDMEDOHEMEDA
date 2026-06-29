//
//  SecuritySettingView.swift
//  Binbon
//
//  Created by Salah Khaled on 22/05/2026.
//

import SwiftUI

struct SecuritySettingView: View {
    
    @Environment(\.router) var router
    @StateObject var viewModel = SecuritySettingViewModel()
    @State private var showDisable2FAAlert = false
    @State private var disable2FAPassword = ""
    @State private var isActivityFilterOpen = false
    @State private var isLoginFilterOpen = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
            Section(AppStrings.twoFactorAuthentication.localized) { twoFactorSection }
            Section(AppStrings.latestActivities.localized) { activitiesSection }
            Section(AppStrings.signInLogs.localized) { signLogSection }
            Section(AppStrings.biometricManagement.localized) { biometricSection }
            Section(AppStrings.changePassword.localized) { passwordSection }
            Section(AppStrings.newDeviceSecurityAlerts.localized) { newDeviceSection }
            }

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
        }
        .adaptiveContentWidth()
        .appBackground()
        .appNavigation(title: AppStrings.privacySettings.localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .onAppear {
            viewModel.fetchSecuritySettings()
        }
        .alert(AppStrings.disableTwoFactorAuthentication.localized, isPresented: $showDisable2FAAlert) {
            SecureField(AppStrings.enterYourPassword.localized, text: $disable2FAPassword)
            Button(AppStrings.cancel.localized, role: .cancel) {
                disable2FAPassword = ""
            }
            Button(AppStrings.disable.localized, role: .destructive) {
                viewModel.disable2FA(password: disable2FAPassword)
                disable2FAPassword = ""
            }
            .disabled(disable2FAPassword.isEmpty)
        } message: {
            Text(AppStrings.enterPasswordToDisable2FA.localized)
        }
        .alert(AppStrings.biometricManagement.localized, isPresented: biometricAlertPresented) {
            Button(AppStrings.alright.localized, role: .cancel) {
                viewModel.biometricAlertMessage = nil
            }
        } message: {
            Text(viewModel.biometricAlertMessage ?? "")
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
    private var twoFactorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.twoFADescription.localized)
                .font(.footnote.weight(.medium))
                .foregroundStyle(.appText)
                .lineLimit(nil)
            
            HStack {
                Spacer()
                AppButton(title: viewModel.twoFactorEnabled ? AppStrings.disable.localized : AppStrings.enable.localized) {
                    switch viewModel.twoFactorEnabled {
                    case true:
                        showDisable2FAAlert = true
                    case false:
                        router.navigate(.twoFactor)
                    }
                }
                .frame(width: 120)
            }
        }
    }
    
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isLoadingActivities && !viewModel.hasAnyActivity {
                activityLoadingState
            } else if let error = viewModel.activitiesError, !viewModel.hasAnyActivity {
                activityErrorState(error)
            } else if !viewModel.hasAnyActivity {
                activityEmptyState(AppStrings.noRecentActivity)
            } else {
                HStack(alignment: .center, spacing: 12) {
                    Text(AppStrings.activityLog.localized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.appWhite)

                    Spacer(minLength: 12)

                    DropdownSelector(
                        selection: $viewModel.activityFilter,
                        onSelectionChange: { _ in viewModel.applyActivityFilter() },
                        onExpandedChange: { isActivityFilterOpen = $0 }
                    )
                }
                .zIndex(1)

                if viewModel.activitySections.isEmpty {
                    activityEmptyState(AppStrings.noActivityInPeriod)
                } else {
                    SecurityActivityTimeline(
                        sections: viewModel.displayedActivitySections,
                        canShowMore: viewModel.canShowMoreActivities,
                        isLoadingMore: viewModel.isLoadingMoreActivities,
                        onShowMore: { viewModel.showMoreActivities() }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: isActivityFilterOpen ? 200 : nil, alignment: .topLeading)
        .onAppear { viewModel.fetchActivitiesIfNeeded() }
    }

    private func activityEmptyState(_ key: String) -> some View {
        Text(key.localized)
            .font(.footnote)
            .foregroundStyle(.appWhite.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 20)
    }

    private var activityLoadingState: some View {
        HStack {
            Spacer()
            ProgressView().tint(.appWhite)
            Spacer()
        }
        .padding(.vertical, 20)
    }

    private func activityErrorState(_ error: APIError) -> some View {
        VStack(spacing: 12) {
            Text(error.localizedMessage())
                .font(.footnote)
                .foregroundStyle(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(AppStrings.retry.localized) {
                viewModel.retryActivities()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.appGold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    private var signLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.isLoadingLoginHistory && !viewModel.hasAnyLoginHistory {
                activityLoadingState
            } else if let error = viewModel.loginHistoryError, !viewModel.hasAnyLoginHistory {
                loginHistoryErrorState(error)
            } else if !viewModel.hasAnyLoginHistory {
                activityEmptyState(AppStrings.noLoginHistory)
            } else {
                HStack(alignment: .center, spacing: 12) {
                    Text(AppStrings.loginHistory.localized)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.appWhite)

                    Spacer(minLength: 12)

                    DropdownSelector(
                        selection: $viewModel.loginHistoryFilter,
                        onSelectionChange: { _ in viewModel.applyLoginHistoryFilter() },
                        onExpandedChange: { isLoginFilterOpen = $0 }
                    )
                }
                .zIndex(1)

                if viewModel.loginHistorySections.isEmpty {
                    activityEmptyState(AppStrings.noLoginInPeriod)
                } else {
                    LoginHistoryTimeline(
                        sections: viewModel.displayedLoginHistorySections,
                        canShowMore: viewModel.canShowMoreLoginHistory,
                        isLoadingMore: viewModel.isLoadingMoreLoginHistory,
                        onShowMore: { viewModel.showMoreLoginHistory() }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: isLoginFilterOpen ? 200 : nil, alignment: .topLeading)
        .onAppear { viewModel.fetchLoginHistoryIfNeeded() }
    }

    private func loginHistoryErrorState(_ error: APIError) -> some View {
        VStack(spacing: 12) {
            Text(error.localizedMessage())
                .font(.footnote)
                .foregroundStyle(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button(AppStrings.retry.localized) {
                viewModel.retryLoginHistory()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.appGold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
    
    private var biometricSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.hasBiometricHardware {
                HStack(spacing: 16) {
                    Image(systemName: viewModel.deviceBiometry.iconName)
                        .font(.system(size: 34))
                        .foregroundStyle(.appYellow)
                        .frame(width: 44)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.deviceBiometry.titleKey.localized)
                            .foregroundStyle(.appWhite)
                            .font(.subheadline.weight(.semibold))
                        
                        Text(AppStrings.biometricLoginDescription.localized)
                            .foregroundStyle(.appWhite.opacity(0.7))
                            .font(.caption)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: biometricBinding)
                        .labelsHidden()
                        .disabled(!viewModel.canUseBiometrics)
                }
                
                if !viewModel.canUseBiometrics {
                    Text(AppStrings.biometricUnavailableMessage.localizedFormat(viewModel.deviceBiometry.titleKey.localized))
                        .font(.footnote)
                        .foregroundStyle(.appOrange)
                        .lineLimit(nil)
                }
            } else {
                Text(AppStrings.biometricNoHardware.localized)
                    .font(.footnote)
                    .foregroundStyle(.appWhite.opacity(0.7))
                    .lineLimit(nil)
            }
        }
    }
    
    private var biometricBinding: Binding<Bool> {
        Binding(
            get: { viewModel.biometricEnabled },
            set: { viewModel.setBiometric(enabled: $0) }
        )
    }
    
    private var biometricAlertPresented: Binding<Bool> {
        Binding(
            get: { viewModel.biometricAlertMessage != nil },
            set: { if !$0 { viewModel.biometricAlertMessage = nil } }
        )
    }
    
    private var passwordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AppTextField(title: AppStrings.currentPassword.localized,
                         placeholder: AppStrings.enterCurrentPassword.localized,
                         isRequired: true,
                         isPassword: true,
                         text: .constant(""))
            
            AppTextField(title: AppStrings.newPassword.localized,
                         placeholder: AppStrings.enterNewPassword.localized,
                         isRequired: true,
                         isPassword: true,
                         text: .constant(""))
            
            AppTextField(title: AppStrings.confirmPassword.localized,
                         placeholder: AppStrings.enterConfirmPassword.localized,
                         isRequired: true,
                         isPassword: true,
                         text: .constant(""))
            
            Text(AppStrings.passwordRequirements.localized)
                .font(.footnote)
                .foregroundStyle(.appText.opacity(0.75))
                .tracking(-0.2)
                .lineLimit(nil)
            
            AppButton(title: AppStrings.updatePassword.localized) {
                
            }
        }
    }
    
    private var newDeviceSection: some View {
        VStack(spacing: 12) {
            // TODO: render real alerts once the new-device alerts endpoint
            // is wired into the view model; using a representative sample for now.
            newDeviceAlertCard(.sample)
        }
        // Last section: ExpandView ignores the bottom safe area, so add room
        // to keep the description clear of the home indicator.
        .padding(.bottom, 40)
    }

    private func newDeviceAlertCard(_ alert: NewDeviceAlert) -> some View {
        VStack(spacing: 14) {
            VStack(spacing: 18) {
                Image("line-md_security-twotone")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(Color.appGold)
                    .frame(width: 50, height: 50)
                
                Text(AppStrings.securityAlertTitle.localized)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.appWhite)
                
                Text(AppStrings.securityAlertDescription.localized)
                    .font(.subheadline.weight(.regular))
                    .foregroundStyle(.appWhite)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                Rectangle()
                    .fill(.appWhite)
                    .frame(height: 0.5)
                
                VStack(spacing: 20) {
                    alertMetaRow(Image("mdi_clock"), text: alert.timeAgo)
                    alertMetaRow(Image("location-pin"), text: alert.location)
                    alertMetaRow(Image(systemName: "iphone"), text: alert.device)
                }
                
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(.appWhite.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.appWhite.opacity(0.5), lineWidth: 0.5)
            )
            
            HStack(spacing: 16) {
                alertButton(title: AppStrings.thisWasMe.localized,
                            background: AnyShapeStyle(AppColor.buttonGradient),
                            foreground: .appWhite) {
                    // confirm: this login was the user
                }

                alertButton(title: AppStrings.thisWasntMe.localized,
                            background: AnyShapeStyle(.appWhite),
                            foreground: .appPurple) {
                    // report: this login was not the user
                }
            }
            .padding(.top, 4)

            Text(AppStrings.newDeviceAlertsDescription.localized)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.appWhite)
                .tracking(-0.24)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
    }

    private func alertMetaRow(_ icon: Image, text: String) -> some View {
        HStack(spacing: 8) {
            icon
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(.appWhite.opacity(0.85))
                .frame(width: 30, height: 30)

            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.appWhite)

            Spacer(minLength: 0)
        }
    }

    private func alertButton(title: String,
                             background: AnyShapeStyle,
                             foreground: Color,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(background, in: RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }

    private var showMoreButton: some View {
        Button {
            // TODO: navigate to the full new-device alerts list
        } label: {
            Text(AppStrings.showMore.localized)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.appWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.appWhite.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.appWhite.opacity(0.5), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        SecuritySettingView()
    }
}
