//
//  ProfileViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 28/04/2026.
//
//  Presentation layer — drives `ProfileView`. Depends only on domain use cases,
//  injected via init (with concrete defaults) so the screen is testable against
//  fakes without touching the network.
//

import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Published
    @Published var error: APIError?
    @Published var isLoading: Bool = false

    @Published var user = Storage.shared.user
    @Published var avatarList: [UserAvatarModel] = []

    @Published var imagePicker = ProfileImageViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Use cases
    private let fetchUserDetailsUseCase: FetchUserDetailsUseCase
    private let updateProfilePhotoUseCase: UpdateProfilePhotoUseCase

    // MARK: - Init
    init(
        fetchUserDetailsUseCase: FetchUserDetailsUseCase,
        updateProfilePhotoUseCase: UpdateProfilePhotoUseCase
    ) {
        self.fetchUserDetailsUseCase = fetchUserDetailsUseCase
        self.updateProfilePhotoUseCase = updateProfilePhotoUseCase

        imagePicker.$uploadImage
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateProfilePhoto()
            }
            .store(in: &cancellables)
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchUserDetailsUseCase: container.makeFetchUserDetailsUseCase(),
            updateProfilePhotoUseCase: container.makeUpdateProfilePhotoUseCase()
        )
    }

    // MARK: - Fetch
    func fetchUserDetails() {
        Task {
            error = nil
            isLoading = true
            defer { isLoading = false }

            do {
                let user = try await fetchUserDetailsUseCase.execute()
                self.user = user
                self.avatarList = user.avatars ?? []
                self.loadProfileImage()
            } catch {
                self.error = Network.shared.mapError(error)
            }
        }
    }

    func updateProfilePhoto() {
        guard let image = imagePicker.uploadImage else { return }

        Task {
            do {
                try await updateProfilePhotoUseCase.execute(image: image)
                Toaster.shared.show(.success(), "Profile photo updated successfully")
            } catch {
                self.error = Network.shared.mapError(error)
                imagePicker.uploadImage = nil
            }
        }
    }

    func loadProfileImage() {
        if user?.profilePhoto == nil {
            imagePicker.initialImage = nil
            imagePicker.uploadImage = nil
        } else {
            Task {
                self.imagePicker.initialImage = await Network.shared.image(user?.profilePhoto ?? "")
            }
        }
    }
}
