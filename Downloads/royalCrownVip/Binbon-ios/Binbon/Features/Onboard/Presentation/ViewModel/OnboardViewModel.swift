//
//  OnboardViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 18/05/2026.
//
//  Presentation layer — drives the onboarding steps. Business work runs through
//  injected use cases; navigation goes through `AppRouter` (`Route`).
//

import Combine

// MARK: - State

enum OnboardState {
    case idle
    case loading
    case success
    case failed(APIError)
}

@MainActor
final class OnboardViewModel: ObservableObject {

    // MARK: - Published
    @Published var suggestions: [OnboardSuggestionResponse] = []
    @Published var selectedUserIds: Set<Int> = []
    @Published var state: OnboardState = .idle

    // MARK: - Input
    var step: OnboardStepEnum?

    // MARK: - State projections (kept for the view's bindings)
    var isLoading: Bool {
        get { if case .loading = state { return true }; return false }
        set { state = newValue ? .loading : .idle }
    }

    var error: APIError? {
        get { if case .failed(let error) = state { return error }; return nil }
        set {
            if let newValue {
                state = .failed(newValue)
            } else if case .failed = state {
                state = .idle
            }
        }
    }

    // MARK: - Use cases
    private let fetchSuggestionsUseCase: FetchOnboardSuggestionsUseCase
    private let followSelectedUseCase: FollowSelectedSuggestionsUseCase
    private let followAllUseCase: FollowAllSuggestionsUseCase
    private let completeOnboardingUseCase: CompleteOnboardingUseCase

    // MARK: - Init
    init(
        fetchSuggestionsUseCase: FetchOnboardSuggestionsUseCase,
        followSelectedUseCase: FollowSelectedSuggestionsUseCase,
        followAllUseCase: FollowAllSuggestionsUseCase,
        completeOnboardingUseCase: CompleteOnboardingUseCase
    ) {
        self.fetchSuggestionsUseCase = fetchSuggestionsUseCase
        self.followSelectedUseCase = followSelectedUseCase
        self.followAllUseCase = followAllUseCase
        self.completeOnboardingUseCase = completeOnboardingUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchSuggestionsUseCase: container.makeFetchOnboardSuggestionsUseCase(),
            followSelectedUseCase: container.makeFollowSelectedSuggestionsUseCase(),
            followAllUseCase: container.makeFollowAllSuggestionsUseCase(),
            completeOnboardingUseCase: container.makeCompleteOnboardingUseCase()
        )
    }

    // MARK: - Suggestions
    func fetchSuggestions() {
        guard let step else {
            state = .failed(APIError(type: .unknown, message: "onboarding_step_not_set".localized))
            return
        }
        Task {
            state = .loading
            do {
                suggestions = try await fetchSuggestionsUseCase.execute(step: step)
                state = .idle
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    var isAllSelected: Bool {
        let allIds = Set(suggestions.compactMap { $0.id })
        return !allIds.isEmpty && selectedUserIds == allIds
    }

    func toggleSelection(_ userId: Int) {
        if selectedUserIds.contains(userId) {
            selectedUserIds.remove(userId)
        } else {
            selectedUserIds.insert(userId)
        }
    }

    func toggleAll() {
        let allIds = Set(suggestions.map { $0.id ?? 0 })
        if selectedUserIds.isSuperset(of: allIds) {
            selectedUserIds.subtract(allIds)
        } else {
            selectedUserIds.formUnion(allIds)
        }
    }

    // MARK: - Actions
    func next() {
        if isAllSelected {
            followAll()
        } else if !selectedUserIds.isEmpty {
            followSelected()
        } else {
            state = .failed(APIError(type: .unknown, message: "select_at_least_one_user".localized))
        }
    }

    func followSelected() {
        Task {
            state = .loading
            do {
                try await followSelectedUseCase.execute(userIds: Array(selectedUserIds))
                complete(action: "next")
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    func followAll() {
        Task {
            state = .loading
            do {
                try await followAllUseCase.execute()
                complete(action: "next")
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    func skip() {
        complete(action: "skip")
    }

    func complete(action: String) {
        Task {
            state = .loading
            do {
                try await completeOnboardingUseCase.execute(action: action)
                handleFinish()
            } catch {
                state = .failed(asAPIError(error))
            }
        }
    }

    // MARK: - Routing
    private func handleFinish() {
        switch step {
        case .step1Singers:
            AppRouter.shared.navigate(.onboard(.step2Famous))
        case .step2Famous:
            AppRouter.shared.navigate(.onboard(.step3Binbon))
        case .step3Binbon:
            Storage.shared.user?.onboardingCompleted = true
            Storage.shared.user?.onboardingRequired = false
            AppRouter.shared.root(.home)
        case .none:
            break
        }
    }

    // MARK: - Helpers
    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
