//
//  SecuritySettingViewModel.swift
//  Binbon
//
//  Created by Salah Khaled on 22/05/2026.
//

import SwiftUI
import Combine

@MainActor
class SecuritySettingViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var isLoading = false
    @Published var error: APIError?
    
    @Published var twoFactorEnabled: Bool = false
    @Published var twoFactorChannel: String = "email"
    @Published var biometricEnabled: Bool = false
    @Published var biometricType: String = "none"
    @Published var biometricMethods: [String] = []
    @Published var newDeviceAlertsEnabled: Bool = false
    @Published var recoveryCodesCount: Int = 0

    @Published var biometricAlertMessage: String?

    // MARK: - Activity Log State
    @Published var activitySections: [SecurityActivitySection] = []
    @Published var isLoadingActivities = false
    @Published var isLoadingMoreActivities = false
    @Published var activitiesError: APIError?
    @Published var activityFilter: ActivityDateFilter = .lastWeek
    @Published var activityDisplayLimit: Int = 4

    private let activityInitialDisplay = 4

    // MARK: - Login History State
    @Published var loginHistorySections: [LoginHistorySection] = []
    @Published var isLoadingLoginHistory = false
    @Published var isLoadingMoreLoginHistory = false
    @Published var loginHistoryError: APIError?
    @Published var loginHistoryFilter: ActivityDateFilter = .lastWeek
    @Published var loginHistoryDisplayLimit: Int = 4

    private let loginHistoryInitialDisplay = 4

    private var rawLoginHistoryItems: [LoginHistoryItem] = []
    private var loginHistoryPagination: SecurityActivityPagination?
    private var hasLoadedLoginHistory = false
    private var isFetchingLoginHistory = false

    var securityModel: SecuritySettingResponse?

    private var rawActivityGroups: [String: [SecurityActivity]] = [:]
    private var activityPagination: SecurityActivityPagination?
    private var hasLoadedActivities = false
    private var isFetchingActivities = false

    // MARK: - Properties
    private let fetchSecuritySettingsUseCase: FetchSecuritySettingsUseCase
    private let updateBiometricUseCase: UpdateBiometricUseCase
    private let disable2FAUseCase: Disable2FAUseCase
    private let fetchSecurityActivityUseCase: FetchSecurityActivityUseCase
    private let fetchLoginHistoryUseCase: FetchLoginHistoryUseCase
    private let biometric = BiometricAuthManager()

    init(fetchSecuritySettingsUseCase: FetchSecuritySettingsUseCase,
         updateBiometricUseCase: UpdateBiometricUseCase,
         disable2FAUseCase: Disable2FAUseCase,
         fetchSecurityActivityUseCase: FetchSecurityActivityUseCase,
         fetchLoginHistoryUseCase: FetchLoginHistoryUseCase) {
        self.fetchSecuritySettingsUseCase = fetchSecuritySettingsUseCase
        self.updateBiometricUseCase = updateBiometricUseCase
        self.disable2FAUseCase = disable2FAUseCase
        self.fetchSecurityActivityUseCase = fetchSecurityActivityUseCase
        self.fetchLoginHistoryUseCase = fetchLoginHistoryUseCase
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchSecuritySettingsUseCase: container.makeFetchSecuritySettingsUseCase(),
            updateBiometricUseCase: container.makeUpdateBiometricUseCase(),
            disable2FAUseCase: container.makeDisable2FAUseCase(),
            fetchSecurityActivityUseCase: container.makeFetchSecurityActivityUseCase(),
            fetchLoginHistoryUseCase: container.makeFetchLoginHistoryUseCase()
        )
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }

    // MARK: - Biometric Capability
    var deviceBiometry: BiometricAuthManager.Biometry { biometric.biometry }
    var hasBiometricHardware: Bool { biometric.hasHardware }
    var canUseBiometrics: Bool { biometric.canEvaluate }


    // MARK: - Lifecycle Methods
    func fetchSecuritySettings() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                let response = try await fetchSecuritySettingsUseCase.execute()
                mapResponseToProperties(response)
            } catch {
                self.error = asAPIError(error)
            }
        }
    }
    
    func isDataNoChanges() -> Bool {
        guard let model = securityModel else { return true }
        
        let twoFactorEnabledMatches = model.twoFactorEnabled == twoFactorEnabled
        let twoFactorChannelMatches = model.twoFactorChannel == twoFactorChannel
        let newDeviceAlertsMatches = model.newDeviceAlertsEnabled == newDeviceAlertsEnabled
        let recoveryCodesMatches = model.recoveryCodesCount == recoveryCodesCount

        return twoFactorEnabledMatches && twoFactorChannelMatches &&
               newDeviceAlertsMatches && recoveryCodesMatches
    }
    
    // MARK: - Helper Methods
    private func mapResponseToProperties(_ response: SecuritySettingResponse?) {
        
        securityModel = response
        
        if let value = response?.twoFactorEnabled {
            twoFactorEnabled = value
        }
        
        if let value = response?.twoFactorChannel {
            twoFactorChannel = value
        }
        
        if let value = response?.biometricType {
            biometricType = value
        }

        if let value = response?.biometricMethods {
            biometricMethods = value
        }

        if let value = response?.newDeviceAlertsEnabled {
            newDeviceAlertsEnabled = value
        }

        if let value = response?.recoveryCodesCount {
            recoveryCodesCount = value
        }

        if let value = response?.biometricEnabled {
            biometricEnabled = value
        }
    }

    // MARK: - Biometric
    func setBiometric(enabled: Bool) {
        let previous = biometricEnabled

        biometricEnabled = enabled

        Task {
            if enabled {
                let auth = await biometric.authenticate(reason: "enable_biometric_reason".localized)
                if case .failure(let biometricError) = auth {
                    biometricEnabled = previous
                    if !biometricError.isSilent {
                        biometricAlertMessage = biometricError.messageKey.localized
                    }
                    return
                }
            }

            await persistBiometric(enabled: enabled, previous: previous)
        }
    }

    private func persistBiometric(enabled: Bool, previous: Bool) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let request = BiometricUpdateRequest(
            enabled: enabled,
            deviceSupported: hasBiometricHardware,
            biometricType: deviceBiometry.apiValue
        )

        do {
            let response = try await updateBiometricUseCase.execute(request: request)
            biometricEnabled = response.biometricEnabled ?? enabled
            if let type = response.biometricType {
                biometricType = type
            }

            let fallbackKey = biometricEnabled ? "biometric_enabled_success" : "biometric_disabled"
            Toaster.shared.show(.success(deviceBiometry.iconName), fallbackKey.localized)

        } catch {
            biometricEnabled = previous
            self.error = asAPIError(error)
        }
    }

    func save() {

    }
    
    func disable2FA(password: String) {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                try await disable2FAUseCase.execute(password: password)
                twoFactorEnabled = false
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    // MARK: - Activity Log
    var canLoadMoreActivities: Bool {
        activityPagination?.hasMore ?? false
    }

    var hasAnyActivity: Bool {
        !rawActivityGroups.isEmpty
    }

    var totalActivityCount: Int {
        activitySections.reduce(0) { $0 + $1.rows.count }
    }

    var displayedActivitySections: [SecurityActivitySection] {
        var remaining = activityDisplayLimit
        var trimmed: [SecurityActivitySection] = []
        for section in activitySections {
            guard remaining > 0 else { break }
            if section.rows.count <= remaining {
                trimmed.append(section)
                remaining -= section.rows.count
            } else {
                trimmed.append(SecurityActivitySection(id: section.id,
                                                       title: section.title,
                                                       rows: Array(section.rows.prefix(remaining))))
                remaining = 0
            }
        }
        return trimmed
    }

    var canShowMoreActivities: Bool {
        activityDisplayLimit < totalActivityCount || canLoadMoreActivities
    }

    func showMoreActivities() {
        if activityDisplayLimit < totalActivityCount {
            activityDisplayLimit = totalActivityCount
        } else if canLoadMoreActivities {
            loadMoreActivities()
        }
    }

    func applyActivityFilter() {
        activityDisplayLimit = activityInitialDisplay
        rebuildActivitySections()
    }

    func fetchActivitiesIfNeeded() {
        guard !hasLoadedActivities else { return }
        loadActivities(page: 1, reset: true)
    }

    func retryActivities() {
        loadActivities(page: 1, reset: true)
    }

    func loadMoreActivities() {
        guard let pagination = activityPagination, pagination.hasMore else { return }
        let nextPage = (pagination.currentPage ?? 1) + 1
        loadActivities(page: nextPage, reset: false)
    }

    private func loadActivities(page: Int, reset: Bool) {
        guard !isFetchingActivities else { return }
        isFetchingActivities = true

        if reset {
            isLoadingActivities = true
        } else {
            isLoadingMoreActivities = true
        }
        activitiesError = nil

        Task {
            defer {
                isLoadingActivities = false
                isLoadingMoreActivities = false
                isFetchingActivities = false
            }

            do {
                let response = try await fetchSecurityActivityUseCase.execute(page: page)
                hasLoadedActivities = true
                if reset { rawActivityGroups.removeAll() }
                merge(groups: response.groups)
                activityPagination = response.pagination
                rebuildActivitySections()
                activityDisplayLimit = reset ? activityInitialDisplay : totalActivityCount

            } catch {
                activitiesError = asAPIError(error)
            }
        }
    }

    private func merge(groups: [String: [SecurityActivity]]?) {
        guard let groups else { return }
        for (key, items) in groups {
            rawActivityGroups[key, default: []].append(contentsOf: items)
        }
    }

    private func rebuildActivitySections() {
        var sections: [SecurityActivitySection] = []
        var rowID = 0

        let reference = Date()
        let calendar = Calendar.current

        let orderedKeys = rawActivityGroups.keys.sorted { lhs, rhs in
            newestDate(in: rawActivityGroups[lhs]) > newestDate(in: rawActivityGroups[rhs])
        }

        for key in orderedKeys {
            let filteredItems = (rawActivityGroups[key] ?? []).filter { item in
                guard let date = SecurityActivityDate.date(from: item.timestamp) else { return true }
                return activityFilter.contains(date, reference: reference, calendar: calendar)
            }

            guard !filteredItems.isEmpty else { continue }

            let sortedItems = filteredItems.sorted {
                (SecurityActivityDate.date(from: $0.timestamp) ?? .distantPast)
                    > (SecurityActivityDate.date(from: $1.timestamp) ?? .distantPast)
            }

            var rows: [SecurityActivityRow] = []
            for item in sortedItems {
                let date = SecurityActivityDate.date(from: item.timestamp)
                rows.append(
                    SecurityActivityRow(
                        id: rowID,
                        title: item.detail ?? "",
                        relativeTime: date.map(SecurityActivityDate.relativeString) ?? "",
                        iconName: SecurityActivityIcon.name(for: item.activityType)
                    )
                )
                rowID += 1
            }

            let header = sortedItems
                .compactMap { SecurityActivityDate.date(from: $0.timestamp) }
                .max()
                .map(SecurityActivityDate.monthTitle) ?? key

            sections.append(SecurityActivitySection(id: key, title: header, rows: rows))
        }

        activitySections = sections
    }

    private func newestDate(in items: [SecurityActivity]?) -> Date {
        (items ?? [])
            .compactMap { SecurityActivityDate.date(from: $0.timestamp) }
            .max() ?? .distantPast
    }

    // MARK: - Login History
    var canLoadMoreLoginHistory: Bool {
        loginHistoryPagination?.hasMore ?? false
    }

    var hasAnyLoginHistory: Bool {
        !rawLoginHistoryItems.isEmpty
    }

    var totalLoginHistoryCount: Int {
        loginHistorySections.reduce(0) { $0 + $1.rows.count }
    }

    var displayedLoginHistorySections: [LoginHistorySection] {
        var remaining = loginHistoryDisplayLimit
        var trimmed: [LoginHistorySection] = []
        for section in loginHistorySections {
            guard remaining > 0 else { break }
            if section.rows.count <= remaining {
                trimmed.append(section)
                remaining -= section.rows.count
            } else {
                trimmed.append(LoginHistorySection(id: section.id,
                                                   title: section.title,
                                                   rows: Array(section.rows.prefix(remaining))))
                remaining = 0
            }
        }
        return trimmed
    }

    var canShowMoreLoginHistory: Bool {
        loginHistoryDisplayLimit < totalLoginHistoryCount || canLoadMoreLoginHistory
    }

    func showMoreLoginHistory() {
        if loginHistoryDisplayLimit < totalLoginHistoryCount {
            loginHistoryDisplayLimit = totalLoginHistoryCount
        } else if canLoadMoreLoginHistory {
            loadMoreLoginHistory()
        }
    }

    func applyLoginHistoryFilter() {
        loginHistoryDisplayLimit = loginHistoryInitialDisplay
        rebuildLoginHistorySections()
    }

    func fetchLoginHistoryIfNeeded() {
        guard !hasLoadedLoginHistory else { return }
        loadLoginHistory(page: 1, reset: true)
    }

    func retryLoginHistory() {
        loadLoginHistory(page: 1, reset: true)
    }

    func loadMoreLoginHistory() {
        guard let pagination = loginHistoryPagination, pagination.hasMore else { return }
        let nextPage = (pagination.currentPage ?? 1) + 1
        loadLoginHistory(page: nextPage, reset: false)
    }

    private func loadLoginHistory(page: Int, reset: Bool) {
        guard !isFetchingLoginHistory else { return }
        isFetchingLoginHistory = true

        if reset {
            isLoadingLoginHistory = true
        } else {
            isLoadingMoreLoginHistory = true
        }
        loginHistoryError = nil

        Task {
            defer {
                isLoadingLoginHistory = false
                isLoadingMoreLoginHistory = false
                isFetchingLoginHistory = false
            }

            do {
                let response = try await fetchLoginHistoryUseCase.execute(page: page)
                hasLoadedLoginHistory = true
                if reset { rawLoginHistoryItems.removeAll() }
                rawLoginHistoryItems.append(contentsOf: response.items ?? [])
                loginHistoryPagination = response.pagination
                rebuildLoginHistorySections()
                // A fresh load shows the preview; a "More" fetch keeps everything loaded visible.
                loginHistoryDisplayLimit = reset ? loginHistoryInitialDisplay : totalLoginHistoryCount

            } catch {
                loginHistoryError = asAPIError(error)
            }
        }
    }

    private func rebuildLoginHistorySections() {
        let reference = Date()
        let calendar = Calendar.current

        let filtered = rawLoginHistoryItems.filter { item in
            guard let date = SecurityActivityDate.date(from: item.loginTime) else { return true }
            return loginHistoryFilter.contains(date, reference: reference, calendar: calendar)
        }

        var buckets: [Date: [LoginHistoryItem]] = [:]
        var undated: [LoginHistoryItem] = []
        for item in filtered {
            if let date = SecurityActivityDate.date(from: item.loginTime) {
                buckets[calendar.startOfDay(for: date), default: []].append(item)
            } else {
                undated.append(item)
            }
        }

        var sections: [LoginHistorySection] = []
        var rowID = 0

        for day in buckets.keys.sorted(by: >) {
            let sortedItems = (buckets[day] ?? []).sorted {
                (SecurityActivityDate.date(from: $0.loginTime) ?? .distantPast)
                    > (SecurityActivityDate.date(from: $1.loginTime) ?? .distantPast)
            }

            var rows: [LoginHistoryRow] = []
            for item in sortedItems {
                rows.append(makeLoginHistoryRow(item, id: rowID))
                rowID += 1
            }
            sections.append(LoginHistorySection(id: LoginHistoryDate.dayKey(for: day),
                                                title: LoginHistoryDate.dayTitle(for: day),
                                                rows: rows))
        }

        if !undated.isEmpty {
            var rows: [LoginHistoryRow] = []
            for item in undated {
                rows.append(makeLoginHistoryRow(item, id: rowID))
                rowID += 1
            }
            sections.append(LoginHistorySection(id: "undated", title: "", rows: rows))
        }

        loginHistorySections = sections
    }

    private func makeLoginHistoryRow(_ item: LoginHistoryItem, id: Int) -> LoginHistoryRow {
        let device = item.deviceName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let location = item.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let title = location.isEmpty ? device : "\(device) · \(location)"

        let time = SecurityActivityDate.date(from: item.loginTime)
            .map(LoginHistoryDate.timeString) ?? (item.loginTime ?? "")

        return LoginHistoryRow(
            id: id,
            title: title,
            time: time,
            iconAsset: LoginHistoryIcon.assetName(for: item.deviceName),
            isNewDevice: item.isNewDevice ?? false
        )
    }

}
