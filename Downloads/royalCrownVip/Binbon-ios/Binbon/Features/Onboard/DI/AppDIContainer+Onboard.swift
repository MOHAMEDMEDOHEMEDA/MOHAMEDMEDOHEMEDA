//
//  AppDIContainer+Onboard.swift
//  Binbon
//
//  Composition root — Onboard feature factories.
//

import Foundation

extension AppDIContainer {

    // MARK: - Data

    func makeOnboardRemoteDataSource() -> OnboardRemoteDataSource {
        MockOnboardRemoteDataSource()
    }

    func makeOnboardingRepository() -> OnboardingRepositoryProtocol {
        OnboardingRepositoryImpl(remote: makeOnboardRemoteDataSource())
    }

    // MARK: - Use cases

    func makeFetchOnboardSuggestionsUseCase() -> FetchOnboardSuggestionsUseCase {
        FetchOnboardSuggestionsUseCase(repository: makeOnboardingRepository())
    }

    func makeFollowSelectedSuggestionsUseCase() -> FollowSelectedSuggestionsUseCase {
        FollowSelectedSuggestionsUseCase(repository: makeOnboardingRepository())
    }

    func makeFollowAllSuggestionsUseCase() -> FollowAllSuggestionsUseCase {
        FollowAllSuggestionsUseCase(repository: makeOnboardingRepository())
    }

    func makeCompleteOnboardingUseCase() -> CompleteOnboardingUseCase {
        CompleteOnboardingUseCase(repository: makeOnboardingRepository())
    }

    // MARK: - Presentation

    @MainActor
    func makeOnboardViewModel() -> OnboardViewModel {
        OnboardViewModel(
            fetchSuggestionsUseCase: makeFetchOnboardSuggestionsUseCase(),
            followSelectedUseCase: makeFollowSelectedSuggestionsUseCase(),
            followAllUseCase: makeFollowAllSuggestionsUseCase(),
            completeOnboardingUseCase: makeCompleteOnboardingUseCase()
        )
    }
}
