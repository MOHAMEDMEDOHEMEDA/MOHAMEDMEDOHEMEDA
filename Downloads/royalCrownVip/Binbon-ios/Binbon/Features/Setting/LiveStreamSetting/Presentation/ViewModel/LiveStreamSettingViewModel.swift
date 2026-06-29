//
//  LiveStreamSettingViewModel.swift
//  Binbon
//
//  Created by Ramez Hamdy on 07/06/2026.
//

import SwiftUI
import Combine

@MainActor
final class LiveStreamSettingViewModel: ObservableObject {

    // MARK: - Published (settings)
    @Published var isLoading = false
    @Published var error: APIError?

    @Published var audience: LiveAudience = .everyone
    @Published var streamPassword = ""
    @Published var allowComments = true
    @Published var allowGifts = true

    /// Whether a password is already saved on the server (the value is never returned).
    private var livePasswordEnabled = false

    // MARK: - Published (schedules)
    @Published var schedules: [LiveSchedule] = []

    /// Working state for the schedule pickers.
    @Published var scheduleDate = Date()
    @Published var scheduleHour = 1      // 1...12
    @Published var scheduleMinute = 0    // 0...59
    @Published var scheduleIsPM = false

    // MARK: - Change detection
    private var original: Snapshot?

    private struct Snapshot {
        let audience: LiveAudience
        let allowComments: Bool
        let allowGifts: Bool
        let passwordEnabled: Bool
    }

    // MARK: - Properties
    private let fetchLiveStreamSettingsUseCase: FetchLiveStreamSettingsUseCase
    private let updateLiveStreamSettingsUseCase: UpdateLiveStreamSettingsUseCase
    private let fetchLiveSchedulesUseCase: FetchLiveSchedulesUseCase
    private let createLiveScheduleUseCase: CreateLiveScheduleUseCase
    private let deleteLiveScheduleUseCase: DeleteLiveScheduleUseCase

    // MARK: - Init
    init(
        fetchLiveStreamSettingsUseCase: FetchLiveStreamSettingsUseCase,
        updateLiveStreamSettingsUseCase: UpdateLiveStreamSettingsUseCase,
        fetchLiveSchedulesUseCase: FetchLiveSchedulesUseCase,
        createLiveScheduleUseCase: CreateLiveScheduleUseCase,
        deleteLiveScheduleUseCase: DeleteLiveScheduleUseCase
    ) {
        self.fetchLiveStreamSettingsUseCase = fetchLiveStreamSettingsUseCase
        self.updateLiveStreamSettingsUseCase = updateLiveStreamSettingsUseCase
        self.fetchLiveSchedulesUseCase = fetchLiveSchedulesUseCase
        self.createLiveScheduleUseCase = createLiveScheduleUseCase
        self.deleteLiveScheduleUseCase = deleteLiveScheduleUseCase
        // Default the schedule pickers to one hour from now so the first slot
        // is always in the future (the backend rejects past times).
        let future = Date().addingTimeInterval(60 * 60)
        let comps = Calendar.current.dateComponents([.hour, .minute], from: future)
        let hour24 = comps.hour ?? 0
        scheduleDate = future
        scheduleIsPM = hour24 >= 12
        let hour12 = hour24 % 12
        scheduleHour = hour12 == 0 ? 12 : hour12
        scheduleMinute = comps.minute ?? 0
    }

    convenience init(container: AppDIContainer = .shared) {
        self.init(
            fetchLiveStreamSettingsUseCase: container.makeFetchLiveStreamSettingsUseCase(),
            updateLiveStreamSettingsUseCase: container.makeUpdateLiveStreamSettingsUseCase(),
            fetchLiveSchedulesUseCase: container.makeFetchLiveSchedulesUseCase(),
            createLiveScheduleUseCase: container.makeCreateLiveScheduleUseCase(),
            deleteLiveScheduleUseCase: container.makeDeleteLiveScheduleUseCase()
        )
    }

    func isDataNoChanges() -> Bool {
        guard let original else { return true }
        let passwordChanged = audience == .passwordProtected && !streamPassword.isEmpty
        return original.audience == audience
            && original.allowComments == allowComments
            && original.allowGifts == allowGifts
            && !passwordChanged
    }

    /// Save is blocked when nothing changed, or the password audience is selected
    /// but no password exists or has been entered yet.
    var isSaveDisabled: Bool {
        let needsPassword = audience == .passwordProtected && !livePasswordEnabled && streamPassword.isEmpty
        return isDataNoChanges() || needsPassword
    }

    /// The composed schedule date+time from the picker working state.
    private var scheduledDateTime: Date? {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: scheduleDate)
        comps.hour = scheduleHour % 12 + (scheduleIsPM ? 12 : 0)
        comps.minute = scheduleMinute
        return Calendar.current.date(from: comps)
    }

    // MARK: - Fetch
    func fetchSettings() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            do {
                let settings = try await fetchLiveStreamSettingsUseCase.execute()
                apply(settings)
            } catch {
                self.error = asAPIError(error)
            }

            await loadSchedules()
        }
    }

    // MARK: - Save (settings PATCH)
    func save() {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            let sendPassword = audience == .passwordProtected && !streamPassword.isEmpty
            let clearPassword = audience != .passwordProtected && livePasswordEnabled

            let request = LiveStreamUpdateRequest(
                commentsEnabled: allowComments,
                giftsEnabled: allowGifts,
                liveVisibility: audience.liveVisibility,
                liveType: audience.liveType,
                livePassword: sendPassword ? streamPassword : nil,
                clearLivePassword: clearPassword ? true : nil
            )

            do {
                let result = try await updateLiveStreamSettingsUseCase.execute(request: request)
                apply(result.settings)
                Toaster.shared.show(.success(), result.message ?? "live_stream_settings_updated".localized)
                AppRouter.shared.back()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    // MARK: - Schedules
    func addSchedule() {
        guard let when = scheduledDateTime, when > Date() else {
            Toaster.shared.show(.error(), "schedule_time_future".localized)
            return
        }

        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }

            let request = LiveScheduleRequest(
                title: "schedule_item_title".localizedFormat(schedules.count + 1),
                // Picked wall-clock labeled UTC; the backend stores it as-is, so the
                // same time is shown to every viewer regardless of country.
                scheduledFor: when.apiScheduledFor,
                liveVisibility: audience.liveVisibility,
                liveType: audience.liveType,
                commentsEnabled: allowComments,
                giftsEnabled: allowGifts
            )

            do {
                let message = try await createLiveScheduleUseCase.execute(request: request)
                Toaster.shared.show(.success(), message ?? "live_stream_scheduled".localized)
                await loadSchedules()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    func deleteSchedule(_ schedule: LiveSchedule) {
        Task {
            isLoading = true
            error = nil
            defer { isLoading = false }
            do {
                let message = try await deleteLiveScheduleUseCase.execute(id: schedule.id)
                Toaster.shared.show(.success(), message ?? "schedule_deleted".localized)
                await loadSchedules()
            } catch {
                self.error = asAPIError(error)
            }
        }
    }

    private func loadSchedules() async {
        do {
            let list = try await fetchLiveSchedulesUseCase.execute()
            schedules = list.items ?? []
        } catch {
            self.error = asAPIError(error)
        }
    }

    private func asAPIError(_ error: Error) -> APIError {
        (error as? APIError) ?? Network.shared.mapError(error)
    }

    // MARK: - Schedule display helpers
    var scheduleDayDisplay: String { scheduleDate.display("EEEE d") }
    var scheduleMonthDisplay: String { scheduleDate.display("MMMM") }
    var scheduleTimeDisplay: String {
        let period = (scheduleIsPM ? "pm" : "am").localized
        return String(format: "%02d:%02d %@", scheduleHour, scheduleMinute, period)
    }

    // MARK: - Mapping
    private func apply(_ settings: LiveStreamSettingResponse?) {
        guard let settings else { return }

        allowComments = settings.commentsEnabled ?? true
        allowGifts = settings.giftsEnabled ?? true
        audience = LiveAudience(visibility: settings.liveVisibility, type: settings.liveType)
        livePasswordEnabled = settings.livePasswordEnabled ?? false
        streamPassword = ""

        original = Snapshot(
            audience: audience,
            allowComments: allowComments,
            allowGifts: allowGifts,
            passwordEnabled: livePasswordEnabled
        )
    }
}
