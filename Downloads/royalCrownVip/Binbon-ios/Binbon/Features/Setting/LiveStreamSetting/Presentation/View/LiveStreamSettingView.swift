//
//  LiveStreamSettingView.swift
//  Binbon
//
//  Created by Ramez Hamdy on 07/06/2026.
//

import SwiftUI

struct LiveStreamSettingView: View {

    @StateObject var viewModel = LiveStreamSettingViewModel()
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var scheduleToDelete: LiveSchedule?

    var body: some View {
        ZStack(alignment: .bottom) {
            ExpandView {
                Section("stream_audience".localized) { audienceSection }
                Section("stream_comments".localized) { commentsSection }
                Section("stream_gifts".localized) { giftsSection }
                Section("stream_schedule".localized) { scheduleSection }
            }
            .adaptiveContentWidth()

            saveButton
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .adaptiveContentWidth()

            if showDatePicker { datePickerOverlay }
            if showTimePicker { timePickerOverlay }
        }
        .appBackground()
        .appNavigation(title: "live_stream_settings".localized)
        .errorAlert(error: $viewModel.error)
        .loadingOverlay($viewModel.isLoading)
        .task { viewModel.fetchSettings() }
        .deleteScheduleAlert(schedule: $scheduleToDelete) { viewModel.deleteSchedule($0) }
    }

    private var saveButton: some View {
        Button { viewModel.save() } label: {
            Text("save_changes".localized)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.buttonGradient))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaveDisabled)
    }

    // MARK: - Audience (who can watch)
    private var audienceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FlowLayout(spacing: 12, lineSpacing: 14) {
                ForEach(LiveAudience.allCases) { option in
                    audienceRadio(option)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.audience == .passwordProtected {
                AppTextField(
                    placeholder: "stream_password".localized,
                    isPassword: true,
                    text: $viewModel.streamPassword,
                    background: .clear
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.audience)
    }

    private func audienceRadio(_ option: LiveAudience) -> some View {
        let selected = viewModel.audience == option
        return Button {
            viewModel.audience = option
        } label: {
            HStack(spacing: 6) {
                ZStack {
                    Circle().strokeBorder(AppColor.textPrimary, lineWidth: 1.5).frame(width: 18, height: 18)
                    if selected { Circle().fill(AppColor.toggleOnColor).frame(width: 9, height: 9) }
                }
                Text(option.title)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppColor.textPrimary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Comments
    private var commentsSection: some View {
        Toggle(isOn: $viewModel.allowComments) {
            Text("allow_comments_in_stream".localized)
                .font(.footnote)
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Gifts
    private var giftsSection: some View {
        Toggle(isOn: $viewModel.allowGifts) {
            Text("allow_gifts_in_stream".localized)
                .font(.footnote)
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Schedule
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("schedule_next_broadcast".localized)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.textPrimary)

            // Day + Month on one row
            HStack(spacing: 10) {
                Text("schedule_day".localized)
                    .font(.footnote)
                    .foregroundStyle(AppColor.textPrimary)
                dropdownPill(viewModel.scheduleDayDisplay) { openDatePicker() }

                Text("schedule_month".localized)
                    .font(.footnote)
                    .foregroundStyle(AppColor.textPrimary)
                dropdownPill(viewModel.scheduleMonthDisplay) { openDatePicker() }
            }

            // Hour row
            HStack(spacing: 10) {
                Text("schedule_hour".localized)
                    .font(.footnote)
                    .foregroundStyle(AppColor.textPrimary)
                dropdownPill(viewModel.scheduleTimeDisplay, showsChevron: false, fixedWidth: 96) {
                    openTimePicker()
                }
                Spacer()
            }

            // Small "Save" pill (adds a slot)
            savePill

            ForEach(viewModel.schedules) { schedule in
                scheduleRow(schedule)
            }
        }
    }

    private func dropdownPill(_ value: String, showsChevron: Bool = true, fixedWidth: CGFloat? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(value)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if showsChevron {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(width: fixedWidth)
            .background(
                Capsule().strokeBorder(AppColor.hairline, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var savePill: some View {
        Button { viewModel.addSchedule() } label: {
            Text("save".localized)
                .font(.footnote.bold())
                .foregroundStyle(AppColor.textPrimary)
                .padding(.vertical, 9)
                .padding(.horizontal, 28)
                .background(
                    Capsule().fill(AppColor.authListFollowingRowGradient)
                )
                .overlay(Capsule().stroke(AppColor.hairline, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
    }

    private func scheduleRow(_ schedule: LiveSchedule) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(schedule.title ?? "")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(schedule.dateDisplay)   \("time_label".localized) \(schedule.timeDisplay)")
                    .font(.caption2)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button { scheduleToDelete = schedule } label: {
                Image(systemName: "trash")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(AppColor.hairline, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("delete".localized))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppColor.hairline, lineWidth: 1.5)
        )
    }

    // MARK: - Picker presentation (mutually exclusive)
    private func openDatePicker() {
        withAnimation {
            showTimePicker = false
            showDatePicker = true
        }
    }

    private func openTimePicker() {
        withAnimation {
            showDatePicker = false
            showTimePicker = true
        }
    }

    // MARK: - Picker overlays
    private var datePickerOverlay: some View {
        ZStack(alignment: .bottom) {
            AppColor.scrim
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showDatePicker = false } }
            DayStripDatePickerSheet(
                selectedDate: $viewModel.scheduleDate,
                minDate: Date(),
                onAccept: { withAnimation { showDatePicker = false } },
                onCancel: { withAnimation { showDatePicker = false } }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var timePickerOverlay: some View {
        ZStack(alignment: .bottom) {
            AppColor.scrim
                .ignoresSafeArea()
                .onTapGesture { withAnimation { showTimePicker = false } }
            TimeWheelPickerSheet(
                hour: $viewModel.scheduleHour,
                minute: $viewModel.scheduleMinute,
                isPM: $viewModel.scheduleIsPM,
                minTime: Calendar.current.isDateInToday(viewModel.scheduleDate) ? Date() : nil,
                onAccept: { withAnimation { showTimePicker = false } },
                onCancel: { withAnimation { showTimePicker = false } }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - View Modifiers
fileprivate extension View {
    func deleteScheduleAlert(
        schedule: Binding<LiveSchedule?>,
        onConfirm: @escaping (LiveSchedule) -> Void
    ) -> some View {
        self.alert(
            "delete_schedule_confirmation".localized,
            isPresented: .init(
                get: { schedule.wrappedValue != nil },
                set: { if !$0 { schedule.wrappedValue = nil } }
            )
        ) {
            Button("cancel".localized, role: .cancel) { schedule.wrappedValue = nil }
            Button("delete".localized, role: .destructive) {
                if let value = schedule.wrappedValue { onConfirm(value) }
                schedule.wrappedValue = nil
            }
        } message: {
            Text("delete_schedule_message".localized)
        }
    }
}

#Preview {
    NavigationView {
        LiveStreamSettingView()
    }
}
