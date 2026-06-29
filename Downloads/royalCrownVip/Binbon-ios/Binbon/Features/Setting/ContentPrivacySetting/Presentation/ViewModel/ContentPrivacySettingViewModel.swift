//
//  ContentPrivacySettingViewModel.swift
//  Binbon
//
//  Created by Ramez Hamdy on 03/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class ContentPrivacySettingViewModel: ObservableObject {

    // MARK: - Published
    @Published var isLoading = false
    @Published var error: APIError?

    /// All available categories from the unified settings payload.
    @Published var categories: [ContentCategory] = []
    /// Ids of the categories the user currently prefers.
    @Published var selectedIds: Set<Int> = []
    @Published var showAllCategories = false

    /// Account is used by someone under 18 years old.
    @Published var isUnderAge = false
    /// Kids mode toggle.
    @Published var kidsModeEnabled = false
    /// Comma-separated list of blocked words / phrases.
    @Published var blockedWords = ""

    /// Round-tripped from the server (no dedicated UI control on this screen).
    private var filterInappropriateContent = false

    /// Snapshot of the last saved/fetched state, used for change detection.
    private var original: Snapshot?

    private struct Snapshot {
        let selectedIds: Set<Int>
        let isUnderAge: Bool
        let kidsModeEnabled: Bool
        let blockedWords: String
        let filterInappropriateContent: Bool
    }

    // MARK: - Properties
    private let fetchContentControlSettingsUseCase: FetchContentControlSettingsUseCase
    private let updateContentControlSettingsUseCase: UpdateContentControlSettingsUseCase

    /// Show the "More…" affordance only when there are more categories than
    /// can comfortably fit at once.
    private let initialVisibleCount = 20

    init(
        fetchContentControlSettingsUseCase: FetchContentControlSettingsUseCase,
        updateContentControlSettingsUseCase: UpdateContentControlSettingsUseCase
    ) {
        self.fetchContentControlSettingsUseCase = fetchContentControlSettingsUseCase
        self.updateContentControlSettingsUseCase = updateContentControlSettingsUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchContentControlSettingsUseCase: container.makeFetchContentControlSettingsUseCase(),
            updateContentControlSettingsUseCase: container.makeUpdateContentControlSettingsUseCase()
        )
    }

    // MARK: - Selection
    func isSelected(_ category: ContentCategory) -> Bool {
        selectedIds.contains(category.id)
    }

    func toggle(_ category: ContentCategory) {
        if selectedIds.contains(category.id) {
            selectedIds.remove(category.id)
        } else {
            selectedIds.insert(category.id)
        }
    }

    /// Categories currently visible (respects the "More…" expansion).
    var visibleCategories: [ContentCategory] {
        guard hasMoreCategories, !showAllCategories else { return categories }
        return Array(categories.prefix(initialVisibleCount))
    }

    var hasMoreCategories: Bool {
        categories.count > initialVisibleCount
    }

    // MARK: - Change detection
    func isDataNoChanges() -> Bool {
        guard let original else { return true }
        return original.selectedIds == selectedIds
            && original.isUnderAge == isUnderAge
            && original.kidsModeEnabled == kidsModeEnabled
            && original.blockedWords == blockedWords
            && original.filterInappropriateContent == filterInappropriateContent
    }

    // MARK: - Fetch
    /// Initializes every section of the screen (categories + selection, age,
    /// kids mode, blocked words) from a single unified request.
    func fetchSettings() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                let settings = try await fetchContentControlSettingsUseCase.execute()
                apply(settings)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    // MARK: - Save
    func save() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            let request = ContentControlUpdateRequest(
                categoryIds: Array(selectedIds),
                isUnder18: isUnderAge,
                kidsModeEnabled: kidsModeEnabled,
                filterInappropriateContent: filterInappropriateContent,
                blockedKeywords: blockedWords
            )

            do {
                let result = try await updateContentControlSettingsUseCase.execute(request: request)
                apply(result.settings)
                Toaster.shared.show(.success(), result.message ?? "content_privacy_settings_updated".localized)
                AppRouter.shared.back()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    // MARK: - Mapping
    private func apply(_ settings: ContentControlSettings?) {
        guard let settings else { return }

        categories = settings.contentTypes?.available ?? []
        if let ids = settings.contentTypes?.selectedCategoryIds {
            selectedIds = Set(ids)
        } else {
            selectedIds = Set((settings.contentTypes?.selected ?? []).map(\.id))
        }

        isUnderAge = settings.age?.isUnder18 ?? false
        kidsModeEnabled = settings.kidsMode?.enabled ?? false
        filterInappropriateContent = settings.safety?.filterInappropriateContent ?? false
        blockedWords = settings.safety?.blockedKeywordsText
            ?? (settings.safety?.blockedKeywords ?? []).joined(separator: ", ")

        original = Snapshot(
            selectedIds: selectedIds,
            isUnderAge: isUnderAge,
            kidsModeEnabled: kidsModeEnabled,
            blockedWords: blockedWords,
            filterInappropriateContent: filterInappropriateContent
        )
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }
}
