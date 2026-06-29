//
//  GameSettingViewModel.swift
//  Binbon
//


import Foundation
import Combine

@MainActor
final class GameSettingViewModel: ObservableObject {

    // MARK: - 1. Game notifications
   
    @Published var gameNotificationsEnabled: Bool = true

    // MARK: - 2. Achievements & points
    @Published var selectedPeriod: GamePeriod = .lastWeek {
        didSet { visibleCount = pageSize }
    }
    @Published private(set) var achievements: [GameAchievement] = []
    @Published private(set) var visibleCount: Int = 2
    @Published var error: APIError?

    private let pageSize = 2

    private let fetchAchievementsUseCase: FetchGameAchievementsUseCase

    init(fetchAchievementsUseCase: FetchGameAchievementsUseCase) {
        self.fetchAchievementsUseCase = fetchAchievementsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(fetchAchievementsUseCase: container.makeFetchGameAchievementsUseCase())
    }

    // MARK: - Lifecycle
    func loadAchievements() {
        guard achievements.isEmpty else { return }
        Task {
            do {
                achievements = try await fetchAchievementsUseCase.execute()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    // MARK: - Derived state
    var filteredAchievements: [GameAchievement] {
        let items = achievements.sorted { $0.date > $1.date }
        guard let cutoff = selectedPeriod.cutoffDate else { return items }
        return items.filter { $0.date >= cutoff }
    }

    var visibleAchievements: [GameAchievement] {
        Array(filteredAchievements.prefix(visibleCount))
    }

    var canLoadMore: Bool {
        visibleCount < filteredAchievements.count
    }

  
    var headerDateText: String {
        guard let date = filteredAchievements.first?.date else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Localizer.shared.language.locale
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Actions
    func loadMore() {
        visibleCount = min(visibleCount + pageSize, filteredAchievements.count)
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
