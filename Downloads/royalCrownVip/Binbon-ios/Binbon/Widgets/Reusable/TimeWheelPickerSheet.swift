//
//  TimeWheelPickerSheet.swift
//  Binbon
//
//  Created by Ramez Hamdy on 07/06/2026.
//

import SwiftUI

/// Bottom-sheet time picker matching the live-stream schedule design: wheel
/// columns for hour (1–12) and minute (00–59) with صباحا/مساءا on the side, and
/// a "ضبط" confirm button. Reused for selecting the broadcast hour.
struct TimeWheelPickerSheet: View {

    @Binding var hour: Int       // 1...12
    @Binding var minute: Int     // 0...59
    @Binding var isPM: Bool
    /// Earliest selectable time-of-day; earlier selections snap forward. `nil` = no floor.
    var minTime: Date? = nil
    var onAccept: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            wheels
            buttons
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(card)
        .onAppear { clampToMinTime() }
        .onChange(of: hour) { clampToMinTime() }
        .onChange(of: minute) { clampToMinTime() }
        .onChange(of: isPM) { clampToMinTime() }
    }

    // MARK: - Minimum-time clamping
    /// Minutes-of-day floor derived from `minTime` (only hour+minute matter).
    private var minMinuteOfDay: Int? {
        guard let minTime else { return nil }
        let c = Calendar.current.dateComponents([.hour, .minute], from: minTime)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    private var selectedMinuteOfDay: Int {
        (hour % 12 + (isPM ? 12 : 0)) * 60 + minute
    }

    /// Snaps the wheels forward to the floor when the user lands on an earlier time.
    private func clampToMinTime() {
        guard let floor = minMinuteOfDay, selectedMinuteOfDay < floor else { return }
        let hour24 = floor / 60
        isPM = hour24 >= 12
        let hour12 = hour24 % 12
        hour = hour12 == 0 ? 12 : hour12
        minute = floor % 60
    }

    // MARK: - Wheels
    private var wheels: some View {
        HStack(spacing: 12) {
            ZStack {
                selectedBox
                HStack(spacing: 8) {
                    wheel(selection: $hour, values: Array(1...12)) { String(format: "%02d", $0) }
                    Text(":")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppColor.textPrimary)
                    wheel(selection: $minute, values: Array(0...59)) { String(format: "%02d", $0) }
                }
            }
            periodColumn
        }
        .frame(height: 180)
    }

    private func wheel(selection: Binding<Int>, values: [Int], label: @escaping (Int) -> String) -> some View {
        Picker("", selection: selection) {
            ForEach(values, id: \.self) { value in
                Text(label(value))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColor.textPrimary)
                    .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(maxWidth: .infinity)
    }

    private var periodColumn: some View {
        VStack(spacing: 10) {
            periodLabel("am", isOn: !isPM)
            periodLabel("pm", isOn: isPM)
        }
        .frame(width: 78)
    }

    private func periodLabel(_ key: String, isOn: Bool) -> some View {
        Button { isPM = (key == "pm") } label: {
            Text(key.localized)
                .font(.footnote.weight(.bold))
                .foregroundStyle(isOn ? AppColor.textOnAccent : AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(isOn ? AnyShapeStyle(AppColor.gold) : AnyShapeStyle(AppColor.textPrimary.opacity(0.1)))
                )
        }
        .buttonStyle(.plain)
    }

    private var selectedBox: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(AppColor.gold, lineWidth: 2.5)
            .fill(AppColor.textPrimary.opacity(0.08))
            .frame(height: 50)
            .allowsHitTesting(false)
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
}
