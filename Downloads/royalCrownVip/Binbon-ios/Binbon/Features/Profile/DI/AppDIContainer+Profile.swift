//
//  AppDIContainer+Profile.swift
//  Binbon
//
//  Composition root — Profile cluster factories (Profile, Follow, FindFriends,
//  ShareProfile, EditProfile).
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeProfileRepository() -> ProfileRepository {
        ProfileRepositoryImpl()
    }

    // MARK: - Use cases

    func makeFetchUserDetailsUseCase() -> FetchUserDetailsUseCase {
        FetchUserDetailsUseCase(repository: makeProfileRepository())
    }

    func makeUpdateProfilePhotoUseCase() -> UpdateProfilePhotoUseCase {
        UpdateProfilePhotoUseCase(repository: makeProfileRepository())
    }

    func makeUpdateUserDetailsUseCase() -> UpdateUserDetailsUseCase {
        UpdateUserDetailsUseCase(repository: makeProfileRepository())
    }

    func makeRecommendedUsersUseCase() -> RecommendedUsersUseCase {
        RecommendedUsersUseCase(repository: makeProfileRepository())
    }

    func makeGetFollowersUseCase() -> GetFollowersUseCase {
        GetFollowersUseCase(repository: makeProfileRepository())
    }

    func makeGetFollowingUseCase() -> GetFollowingUseCase {
        GetFollowingUseCase(repository: makeProfileRepository())
    }

    func makeFollowUserUseCase() -> FollowUserUseCase {
        FollowUserUseCase(repository: makeProfileRepository())
    }

    func makeUnfollowUserUseCase() -> UnfollowUserUseCase {
        UnfollowUserUseCase(repository: makeProfileRepository())
    }

    func makeRemoveFollowerUseCase() -> RemoveFollowerUseCase {
        RemoveFollowerUseCase(repository: makeProfileRepository())
    }

    func makeShareLinkUseCase() -> ShareLinkUseCase {
        ShareLinkUseCase(repository: makeProfileRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            fetchUserDetailsUseCase: makeFetchUserDetailsUseCase(),
            updateProfilePhotoUseCase: makeUpdateProfilePhotoUseCase()
        )
    }

    @MainActor
    func makeFollowViewModel() -> FollowViewModel {
        FollowViewModel(
            getFollowersUseCase: makeGetFollowersUseCase(),
            getFollowingUseCase: makeGetFollowingUseCase(),
            followUserUseCase: makeFollowUserUseCase(),
            unfollowUserUseCase: makeUnfollowUserUseCase(),
            removeFollowerUseCase: makeRemoveFollowerUseCase()
        )
    }

    @MainActor
    func makeFindFriendsViewModel() -> FindFriendsViewModel {
        FindFriendsViewModel(
            recommendedUsersUseCase: makeRecommendedUsersUseCase(),
            followUserUseCase: makeFollowUserUseCase(),
            unfollowUserUseCase: makeUnfollowUserUseCase()
        )
    }

    @MainActor
    func makeShareProfileViewModel() -> ShareProfileViewModel {
        ShareProfileViewModel(shareLinkUseCase: makeShareLinkUseCase())
    }

    @MainActor
    func makeEditProfileViewModel() -> EditProfileViewModel {
        EditProfileViewModel(
            updateUserDetailsUseCase: makeUpdateUserDetailsUseCase(),
            fetchUserDetailsUseCase: makeFetchUserDetailsUseCase(),
            settingRepo: makeSettingRepo()
        )
    }
}
