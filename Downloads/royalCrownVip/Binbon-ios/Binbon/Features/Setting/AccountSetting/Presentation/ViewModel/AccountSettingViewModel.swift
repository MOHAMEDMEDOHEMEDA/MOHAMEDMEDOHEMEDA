//
//  AccountSettingViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 01/05/2026.
//

import UIKit
import Combine

@MainActor
final class AccountSettingViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var username = ""
    @Published var bio = ""
    @Published var gender: GenderType = .male
    @Published var birthday = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var profileSliderEnabled = false
    @Published var hideSocialLinks = false
    @Published var avatarId: Int?
    @Published var avatarList: [UserAvatarModel] = []
    @Published var deviceList: [DeviceSettingModel] = []
    @Published var socialList: [SocialMediaModel] = []
    @Published var socialURLs: [String: String] = [:]
    @Published var socialLinkLoading: [String: Bool] = [:]
    
    /// UI
    @Published var error: APIError?
    @Published var isLoading: Bool = false
    @Published var uploadAvatarLoading: Bool = false
    @Published var logoutAllLoading: Bool = false
    @Published var deviceLoading: [Int: Bool] = [:]
    
    private let fetchProfileSettingUseCase: FetchProfileSettingUseCase
    private let saveProfileSettingUseCase: SaveProfileSettingUseCase
    private let deviceLogoutUseCase: DeviceLogoutUseCase
    private let deviceLogoutAllUseCase: DeviceLogoutAllUseCase
    private let addUserLinkUseCase: AddUserLinkUseCase
    private let deleteUserLinkUseCase: DeleteUserLinkUseCase
    private let uploadAvatarUseCase: UploadAvatarUseCase
    private let deleteAvatarUseCase: DeleteAvatarUseCase

    var accountSettingResponse: AccountSettingResponse?

    init(fetchProfileSettingUseCase: FetchProfileSettingUseCase,
         saveProfileSettingUseCase: SaveProfileSettingUseCase,
         deviceLogoutUseCase: DeviceLogoutUseCase,
         deviceLogoutAllUseCase: DeviceLogoutAllUseCase,
         addUserLinkUseCase: AddUserLinkUseCase,
         deleteUserLinkUseCase: DeleteUserLinkUseCase,
         uploadAvatarUseCase: UploadAvatarUseCase,
         deleteAvatarUseCase: DeleteAvatarUseCase) {
        self.fetchProfileSettingUseCase = fetchProfileSettingUseCase
        self.saveProfileSettingUseCase = saveProfileSettingUseCase
        self.deviceLogoutUseCase = deviceLogoutUseCase
        self.deviceLogoutAllUseCase = deviceLogoutAllUseCase
        self.addUserLinkUseCase = addUserLinkUseCase
        self.deleteUserLinkUseCase = deleteUserLinkUseCase
        self.uploadAvatarUseCase = uploadAvatarUseCase
        self.deleteAvatarUseCase = deleteAvatarUseCase

        let user = Storage.shared.user
        self.username = user?.username ?? ""
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchProfileSettingUseCase: container.makeFetchProfileSettingUseCase(),
            saveProfileSettingUseCase: container.makeSaveProfileSettingUseCase(),
            deviceLogoutUseCase: container.makeDeviceLogoutUseCase(),
            deviceLogoutAllUseCase: container.makeDeviceLogoutAllUseCase(),
            addUserLinkUseCase: container.makeAddUserLinkUseCase(),
            deleteUserLinkUseCase: container.makeDeleteUserLinkUseCase(),
            uploadAvatarUseCase: container.makeUploadAvatarUseCase(),
            deleteAvatarUseCase: container.makeDeleteAvatarUseCase()
        )
    }


    // MARK: - Methods
    func fetchProfileSetting() {
        /// Network call
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                let response = try await fetchProfileSettingUseCase.execute()
                updateField(response)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func updateField(_ response: AccountSettingResponse?) {
        
        accountSettingResponse = response
        
        username = response?.username ?? ""
        bio = response?.bio ?? ""
        
        if let gender = response?.gender?.lowercased() {
            self.gender = GenderType(rawValue: gender) ?? .male
        }
        
        birthday = response?.dateOfBirth ?? ""
        phone = response?.phone ?? ""
        email = response?.email ?? ""
        avatarList = (response?.avatars ?? []).sorted(by: { $0.sortOrder ?? 0 < $1.sortOrder ?? 0})
        deviceList = response?.connectedDevices ?? []
        socialList = response?.socialLinks?.items ?? []
        
        socialURLs.removeAll()
        for social in socialList {
            if let platform = social.platform?.lowercased() {
                socialURLs[platform] = social.url ?? ""
            }
        }
        
        avatarId = response?.avatars?.first(where: { $0.isPrimary == true })?.id
        profileSliderEnabled = response?.profilePhotoSliderEnabled ?? false
        hideSocialLinks = response?.socialLinks?.hideSocialLinks ?? false
    }
    
    func isDataNoChanges() -> Bool {
        guard let response = accountSettingResponse else { return false }
        
        return response.username == username &&
        response.bio == bio &&
        GenderType(rawValue: response.gender ?? "") == gender &&
        response.dateOfBirth == birthday &&
        response.phone == phone &&
        response.email == email &&
        (response.avatars?.first(where: { $0.isPrimary == true })?.id) == avatarId &&
        response.profilePhotoSliderEnabled == profileSliderEnabled &&
        response.socialLinks?.hideSocialLinks == hideSocialLinks
    }
    
    func save() {
        /// Network call
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }
            
            let request = SaveAccountRequest(username: username,
                                             bio: bio,
                                             phone: phone,
                                             email: email,
                                             dateOfBirth: birthday,
                                             gender: gender.rawValue,
                                             profilePhotoSliderEnabled: profileSliderEnabled,
                                             hideSocialLinks: hideSocialLinks,
                                             avatarId: avatarId)

            do {
                let response = try await saveProfileSettingUseCase.execute(request: request)

                /// Update photo
                if let photoUrl = response.avatar?.profilePhotoUrl {
                    Storage.shared.user?.profilePhoto = photoUrl
                }

                /// Update Avatar Preference
                if let sliderEnabled = response.profilePhotoSliderEnabled {
                    Storage.shared.user?.profilePhotoSliderEnabled = sliderEnabled
                }

                /// Dismiss
                Toaster.shared.show(.success(), "profile_settings_updated".localized, 4)
                AppRouter.shared.back()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func signOut(_ id: Int) {
        /// Network call
        Task {
            error = nil
            deviceLoading[id] = true
            defer { deviceLoading[id] = false }
            
            do {
                _ = try await deviceLogoutUseCase.execute(id: id)
                deviceList.removeAll(where: { $0.id == id })
                Toaster.shared.show(.success("arrow.left.square"), "device_logged_out".localized)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func signOutOthers() {
        /// Network call
        Task {
            error = nil
            logoutAllLoading = true
            defer { logoutAllLoading = false }
            
            do {
                _ = try await deviceLogoutAllUseCase.execute()
                deviceList.removeAll(where: { $0.isActive == false })
                Toaster.shared.show(.success("arrow.left.square"), "other_devices_logged_out".localized)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    // MARK: - Social Media Methods
    func isLinked(platform: String) -> Bool {
        return socialList.contains { $0.platform?.lowercased() == platform.lowercased() }
    }
    
    func linkSocial(platform: String) {
        guard let url = socialURLs[platform] else {
            self.error = APIError(type: .unknown, message: "validation_enter_url".localized)
            return
        }
        
        if let error = FormValidation.url(url) {
            self.error = APIError(type: .unknown, message: error)
            return
        }
        
        /// Network call
        Task {
            error = nil
            socialLinkLoading[platform] = true
            defer { socialLinkLoading[platform] = false }
            
            let request = AccountLinkRequest(title: platform, url: url)

            do {
                let links = try await addUserLinkUseCase.execute(request: request)
                socialList = links.map {
                    SocialMediaModel(id: $0.id, platform: $0.title, url: $0.url)
                }
                Toaster.shared.show(.success("link.circle"), "platform_linked".localizedFormat(platform.capitalized))
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func unlinkSocial(platform: String) {
        guard let social = socialList.first(where: { $0.platform?.lowercased() == platform.lowercased() }),
              let id = social.id else {
            return
        }
        
        /// Network call
        Task {
            error = nil
            socialLinkLoading[platform] = true
            defer { socialLinkLoading[platform] = false }
            
            do {
                try await deleteUserLinkUseCase.execute(id: id)
                socialList.removeAll(where: { $0.id == id })
                socialURLs[platform] = ""
                Toaster.shared.show(.error("link.circle"), "platform_unlinked".localizedFormat(platform.capitalized))
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func uploadAvatar(_ image: UIImage) {
        
        /// Network call
        Task {
            error = nil
            uploadAvatarLoading = true
            defer { uploadAvatarLoading = false }
            
            do {
                let response = try await uploadAvatarUseCase.execute(image: image)

                guard let avatar = response.avatarUploaded?.first else {
                    self.error = APIError(type: .unknown, message: "profile_photo_upload_failed".localized)
                    return
                }

                avatarList.append(avatar)

                /// Update User Cache
                if avatar.isPrimary == true {
                    avatarId = avatar.id
                    Storage.shared.user?.profilePhoto = avatar.url
                }

                Toaster.shared.show(.success(), "profile_photo_uploaded".localized)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func deleteAvatar(_ id: Int) {
        
        /// Network call
        Task {
            error = nil
            uploadAvatarLoading = true
            defer { uploadAvatarLoading = false }
            
            do {
                let avatarModel = try await deleteAvatarUseCase.execute(id: id)

                /// Update Avatar UI
                avatarList.removeAll(where: { $0.id == avatarModel.deletedAvatarId })
                avatarId = avatarModel.primaryAvatarId

                /// Update Response
                accountSettingResponse?.avatars?.removeAll(where: { $0.id == avatarModel.deletedAvatarId })
                if let index = accountSettingResponse?.avatars?.firstIndex(where: { $0.id == avatarModel.primaryAvatarId }) {
                    accountSettingResponse?.avatars?[index].isPrimary = true
                }

                /// Update User Cache
                if let photoUrl = avatarModel.profilePhotoUrl, !photoUrl.isEmpty {
                    Storage.shared.user?.profilePhoto = photoUrl
                } else if avatarModel.remainingAvatars == 0 {
                    Storage.shared.user?.profilePhoto = nil
                }
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    // MARK: - Helpers
    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
    
}
