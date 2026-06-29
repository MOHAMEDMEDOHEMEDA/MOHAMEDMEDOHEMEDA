//
//  EditProfileViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 21/04/2026.
//

import SwiftUI
import Combine

@MainActor
class EditProfileViewModel: ObservableObject {

    // MARK: - Published
    @Published var error: APIError?
    @Published var isLoading: Bool = false

    @Published var fullname: String = ""
    @Published var username: String = ""
    @Published var bio: String = ""
    @Published var gender: GenderType = .male
    @Published var dateOfBirth: String = ""
    @Published var userDidSave: Bool = false
    @Published var avatarList: [UserAvatarModel] = []
    @Published var uploadAvatarLoading: Bool = false

    // MARK: - Use cases / repositories
    private let updateUserDetailsUseCase: UpdateUserDetailsUseCase
    private let fetchUserDetailsUseCase: FetchUserDetailsUseCase
    private let settingRepo: SettingRepoProtocol

    // MARK: - Gender String Binding
    var genderString: Binding<String> {
        Binding(
            get: { self.gender.rawValue.capitalized },
            set: { self.gender = GenderType(rawValue: $0.lowercased()) ?? .male }
        )
    }

    // MARK: - Init
    init(
        updateUserDetailsUseCase: UpdateUserDetailsUseCase,
        fetchUserDetailsUseCase: FetchUserDetailsUseCase,
        settingRepo: SettingRepoProtocol
    ) {
        self.updateUserDetailsUseCase = updateUserDetailsUseCase
        self.fetchUserDetailsUseCase = fetchUserDetailsUseCase
        self.settingRepo = settingRepo
        syncUser()
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            updateUserDetailsUseCase: container.makeUpdateUserDetailsUseCase(),
            fetchUserDetailsUseCase: container.makeFetchUserDetailsUseCase(),
            settingRepo: container.makeSettingRepo()
        )
    }

    // MARK: - Request
    var request: EditProfileRequest {
        EditProfileRequest(
            fullname:    fullname,
            username:    username == Storage.shared.user?.username ? nil : username,
            bio:         bio,
            gender:      gender.rawValue,
            dateOfBirth: dateOfBirth
        )
    }

    func syncUser() {
        let user = Storage.shared.user
        self.fullname    = user?.fullname ?? ""
        self.username    = user?.username ?? ""
        self.bio         = user?.bio ?? ""
        self.gender      = GenderType(rawValue: user?.gender ?? "male") ?? .male
        self.dateOfBirth = user?.dateOfBirth ?? ""

        /// Image
        self.avatarList = user?.avatars ?? []
    }

    // MARK: - Save
    func save() {

        if let error = FormValidation.fullName(fullname) {
            self.error = APIError(type: .request, message: error)
            return
        }

        if let error = FormValidation.username(username) {
            self.error = APIError(type: .request, message: error)
            return
        }

        if let error = FormValidation.check(genderString.wrappedValue, title: "Gender") {
            self.error = APIError(type: .request, message: error)
            return
        }

        if let error = FormValidation.dateOfBirth(dateOfBirth) {
            self.error = APIError(type: .request, message: error)
            return
        }


        Task {
            userDidSave = false
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                _ = try await updateUserDetailsUseCase.execute(request)
                userDidSave = true
                Storage.shared.user?.newRegister = false
            } catch {
                self.error = Network.shared.mapError(error)
            }
        }
    }

    func fetchUserDetails() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                _ = try await fetchUserDetailsUseCase.execute()
                syncUser()
            } catch {
                self.error = Network.shared.mapError(error)
            }
        }
    }

    func uploadAvatar(_ image: UIImage) {

        /// Network call
        Task {
            error = nil
            uploadAvatarLoading = true
            defer { uploadAvatarLoading = false }

            let response = await settingRepo.uploadAvatar(image: image)

            switch response {
            case .success(let response):
                if response.status == true, let avatar = response.data?.avatarUploaded?.first {
                    avatarList.append(avatar)

                    /// Update User Cache
                    if avatar.isPrimary == true {
                        Storage.shared.user?.profilePhoto = avatar.url
                    }

                    Toaster.shared.show(.success(), response.message ?? "profile_photo_uploaded".localized)
                } else {
                    self.error = APIError(type: .unknown, message: response.message ?? "profile_photo_upload_failed".localized)
                }
            case .failure(let error):
                self.error = error
            }
        }
    }

    func deleteAvatar(_ id: Int) {

        /// Network call
        Task {
            error = nil
            uploadAvatarLoading = true
            defer { uploadAvatarLoading = false }

            let response = await settingRepo.deleteAvatar(id: id)

            switch response {
            case .success(let response):
                if response.status == true, let avatarModel = response.data {

                    /// Update Avatar UI
                    avatarList.removeAll(where: { $0.id == avatarModel.deletedAvatarId })

                    /// Update Response
                    Storage.shared.user?.avatars?.removeAll(where: { $0.id == avatarModel.deletedAvatarId })
                    if let index = Storage.shared.user?.avatars?.firstIndex(where: { $0.id == avatarModel.primaryAvatarId }) {
                        Storage.shared.user?.avatars?[index].isPrimary = true
                    }


                    /// Update User Cache
                    if let photoUrl = avatarModel.profilePhotoUrl, !photoUrl.isEmpty {
                        Storage.shared.user?.profilePhoto = photoUrl
                    } else if avatarModel.remainingAvatars == 0 {
                        Storage.shared.user?.profilePhoto = nil
                    }

                } else {
                    Toaster.shared.show(.error(), response.message ?? "profile_photo_delete_failed".localized)
                }
            case .failure(let error):
                self.error = error
            }
        }
    }
}
