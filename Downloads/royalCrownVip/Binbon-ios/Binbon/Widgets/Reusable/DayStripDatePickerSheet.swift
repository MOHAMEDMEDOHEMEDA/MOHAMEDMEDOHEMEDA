//
//  DayStripDatePickerSheet.swift
//  Binbon
//
//  Created by Ramez Hamdy on 07/06/2026.
//

import SwiftUI

/// Bottom-sheet date picker matching the live-stream schedule design: a month
/// navigator with a horizontal strip of days (day number + weekday), and a
/// "ضبط" confirm button. Reused for selecting the broadcast day.
struct DayStripDatePickerSheet: View {

    @Binding var selectedDate: Date
    /// Earliest selectable day; earlier days are disabled. `nil` = no lower bound.
    var minDate: Date? = nil
    var onAccept: () -> Void
    var onCancel: () -> Void

    @State private var monthAnchor = Date()
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 18) {
            monthNav
            dayStrip
            buttons
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(card)
        .onAppear { monthAnchor = startOfMonth(selectedDate) }
    }

    // MARK: - Month navigation
    private var monthNav: some View {
        HStack {
            navButton(systemName: "chevron.backward", disabled: !canGoBack) { changeMonth(-1) }
            Spacer()
            Text(monthYearLabel)
                .font(.headline.bold())
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            navButton(systemName: "chevron.forward") { changeMonth(1) }
        }
        .padding(.horizontal, 6)
    }

    private func navButton(systemName: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppColor.textPrimary)
                .frame(width: 34, height: 34)
                .background(AppColor.textPrimary.opacity(0.12), in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.35 : 1)
    }

    private var canGoBack: Bool {
        guard let minDate else { return true }
        return startOfMonth(monthAnchor) > startOfMonth(minDate)
    }

    private func isPast(_ day: Int) -> Bool {
        guard let minDate else { return false }
        return date(for: day) < calendar.startOfDay(for: minDate)
    }

    // MARK: - Day strip
    private var dayStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(daysInMonth, id: \.self) { day in
                        dayCell(day)
                            .id(day)
                    }
                }
                .padding(.horizontal, 4)
            }
            .onAppear {
                if let day = selectedDayInMonth { proxy.scrollTo(day, anchor: .center) }
            }
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let isSelected = day == selectedDayInMonth
        let disabled = isPast(day)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { select(day: day) }
        } label: {
            VStack(spacing: 6) {
                Text(weekdayShort(for: day))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isSelected ? AppColor.textOnAccent : AppColor.textSecondary)
                Text("\(day)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? AppColor.textOnAccent : AppColor.textPrimary)
            }
            .frame(width: 52, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppColor.gold) : AnyShapeStyle(AppColor.textPrimary.opacity(0.06)))
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .opacity(disabled ? 0.35 : 1)
    }

    // MARK: - Buttons
    private var buttons: some View {
        HStack(spacing: 12) {
            Button { onCancel() } label: {
                Text("cancel".localized)
                    .font(.callout.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.hairline, lineWidth: 1.5))
            }
            .buttonStyle(.plain)

            Button { onAccept() } label: {
                Text("picker_set".localized)
                    .font(.callout.bold())
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(RoundedRectangle(cornerRadius: 12).fill(AppColor.authListFollowingRowGradient))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColor.hairline, lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(AppColor.datePickerPanelGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppColor.gold.opacity(0.5), lineWidth: 1.5)
            )
            .shadow(color: AppColor.authListRowShadowColor, radius: 18, y: 6)
    }

    // MARK: - Calendar helpers
    private var daysInMonth: [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: monthAnchor) else { return Array(1...28) }
        return Array(range)
    }

    private var selectedDayInMonth: Int? {
        guard calendar.isDate(selectedDate, equalTo: monthAnchor, toGranularity: .month) else { return nil }
        return calendar.component(.day, from: selectedDate)
    }

    private func date(for day: Int) -> Date {
        var comps = calendar.dateComponents([.year, .month], from: monthAnchor)
        comps.day = day
        return calendar.date(from: comps) ?? monthAnchor
    }

    private func select(day: Int) {
        selectedDate = date(for: day)
    }

    private func weekdayShort(for day: Int) -> String {
        date(for: day).display("EEE")
    }

    private var monthYearLabel: String {
        monthAnchor.display("MMMM yyyy")
    }

    private func changeMonth(_ delta: Int) {
        guard let next = calendar.date(byAdding: .month, value: delta, to: monthAnchor) else { return }
        withAnimation { monthAnchor = startOfMonth(next) }
    }

    private func startOfMonth(_ date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}
