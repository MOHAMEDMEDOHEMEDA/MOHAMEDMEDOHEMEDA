//
//  StoryLiveEventSheet.swift
//  Binbon
//

import SwiftUI

struct StoryLiveEventSheet: View {

    enum Step {
        case dateTime
        case duration
    }

    var onCancel: () -> Void
    var onDone: (Date, TimeInterval) -> Void

    @State private var step: Step = .dateTime
    @State private var selectedDayIndex = 0
    @State private var selectedHour = 17
    @State private var selectedMinute = 5
    @State private var durationHours = 0
    @State private var durationMinutes = 30

    private let calendar = Calendar.current
    private let dayOptions: [Date]
    private let minuteOptions = Array(stride(from: 0, through: 55, by: 5))

    private var panelGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "FF9B7A"), Color(hex: "D4567A"), Color(hex: "83489C")],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    init(
        onCancel: @escaping () -> Void,
        onDone: @escaping (Date, TimeInterval) -> Void
    ) {
        self.onCancel = onCancel
        self.onDone = onDone

        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        self.dayOptions = (0..<60).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    header
                    pickerSection
                    nextButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(panelGradient)
                )
                .colorScheme(.light)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(step == .dateTime ? "story_live_set_date_time".localized : "story_live_set_duration".localized)
                .font(.headline.weight(.bold))
                .foregroundStyle(.black)
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
    }

    private var pickerSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .frame(height: 44)
                .allowsHitTesting(false)

            pickers
        }
        .frame(height: 180)
    }

    @ViewBuilder
    private var pickers: some View {
        switch step {
        case .dateTime:
            HStack(spacing: 0) {
                wheel(selection: $selectedDayIndex, values: Array(dayOptions.indices)) { index in
                    dayOptions[index].display("MMM d")
                }
                wheel(selection: $selectedHour, values: Array(0...23)) { String(format: "%02d", $0) }
                wheel(selection: $selectedMinute, values: minuteOptions) { String(format: "%02d", $0) }
            }
        case .duration:
            HStack(spacing: 0) {
                wheel(selection: $durationHours, values: Array(0...12)) { "\($0)" }
                durationLabel("story_live_hours".localized)
                wheel(selection: $durationMinutes, values: minuteOptions) { String(format: "%02d", $0) }
                durationLabel("story_live_minutes".localized)
            }
        }
    }

    private func durationLabel(_ title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(0.9))
            .frame(width: 56)
    }

    private func wheel<Value: Hashable>(
        selection: Binding<Value>,
        values: [Value],
        label: @escaping (Value) -> String
    ) -> some View {
        Picker("", selection: selection) {
            ForEach(values, id: \.self) { value in
                Text(label(value))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.black)
                    .tag(value)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
        .frame(maxWidth: .infinity)
    }

    private var nextButton: some View {
        Button(action: handleNext) {
            Text("next".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(nextButtonGradient, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var nextButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "83489C"), Color(hex: "E14554")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func handleNext() {
        switch step {
        case .dateTime:
            step = .duration
        case .duration:
            onDone(composedDate, composedDuration)
        }
    }

    private var composedDate: Date {
        guard dayOptions.indices.contains(selectedDayIndex) else { return Date() }
        var components = calendar.dateComponents([.year, .month, .day], from: dayOptions[selectedDayIndex])
        components.hour = selectedHour
        components.minute = selectedMinute
        return calendar.date(from: components) ?? Date()
    }

    private var composedDuration: TimeInterval {
        TimeInterval(durationHours * 3600 + durationMinutes * 60)
    }
}
