//
//  ActivityViewModel.swift
//  Binbon
//
//  Created by ahmedkamal on 17/06/2026.
//

import Combine

@MainActor
final class ActivityViewModel: ObservableObject {

    @Published private(set) var items: [ActivityItem] = []
    @Published var isLoading = false
    @Published var error: APIError?

    private let fetchActivityUseCase: FetchActivityUseCase
    private let followUseCase: FollowFromActivityUseCase

    init(fetchActivityUseCase: FetchActivityUseCase, followUseCase: FollowFromActivityUseCase) {
        self.fetchActivityUseCase = fetchActivityUseCase
        self.followUseCase = followUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        let repository = container.makeActivityRepository()
        self.init(
            fetchActivityUseCase: FetchActivityUseCase(repository: repository),
            followUseCase: FollowFromActivityUseCase(repository: repository)
        )
    }

    func onAppear() {
        guard items.isEmpty else { return }
        fetch()
    }

    func fetch() {
        Task { await fetchAsync() }
    }

    private func fetchAsync() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let feed = try await fetchActivityUseCase.execute()
            items = feed.items ?? []
        } catch {
            self.error = (error as? APIError) ?? Network.shared.mapError(error)
        }
    }

    func followBack(_ item: ActivityItem) {
        guard let userId = item.userId else { return }
        Task {
            do {
                try await followUseCase.execute(userId: userId)
                await fetchAsync()
            } catch {
                self.error = (error as? APIError) ?? Network.shared.mapError(error)
            }
        }
    }
}
