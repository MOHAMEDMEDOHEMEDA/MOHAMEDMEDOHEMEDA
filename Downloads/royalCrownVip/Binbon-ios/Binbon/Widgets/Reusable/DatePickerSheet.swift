//
//  DatePickerSheet.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

struct DatePickerSheet: View {
    
    @Binding var selectedDate: String
    var maxDate: Date = Date()
    var onAccept: () -> Void
    var onCancel: () -> Void
    
    @State private var originalDate: String = ""
    
    private let calendar = Calendar.current
    private var monthSymbols: [String] { calendar.monthSymbols }
    
    private var panelGradient: LinearGradient { AppColor.datePickerPanelGradient }
    
    private var gold: Color { AppColor.gold }
    
    // MARK: - String <-> Date helpers
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.calendar = calendar
        return f
    }
    
    private var selection: Date {
        dateFormatter.date(from: selectedDate) ?? maxDate
    }
    
    private func updateSelectedDate(_ date: Date) {
        selectedDate = dateFormatter.string(from: min(date, maxDate))
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 50) {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 12)
                
                wheelSection
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
            }
            .background(
                Image("DatePicker")
                    .resizable()
                    .scaledToFill()
            )
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
            
            footerButtons
        }
        .onAppear {
            originalDate = selectedDate

            if selectedDate.isEmpty || dateFormatter.date(from: selectedDate) == nil {
                selectedDate = dateFormatter.string(from: maxDate)
            }
        }
    }
    
    private var header: some View {
        ZStack {
            Text("select_date_of_birth".localized)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.appText)
            
            HStack {
                Spacer()
            }
        }
    }
    
    private var wheelSection: some View {
        HStack(spacing: 8) {
            ZStack {
                dayPicker
                selectedBox
            }
            .frame(maxWidth: .infinity)
            
            ZStack {
                monthPicker
                selectedBox
            }
            .frame(maxWidth: .infinity)
            
            ZStack {
                yearPicker
                selectedBox
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 196)
    }
    
    private var selectedBox: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(gold, lineWidth: 2.5)
            .fill(Color.appText.opacity(0.08))
            .frame(height: 52)
            .allowsHitTesting(false)
            .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
    }
    
    private var dayPicker: some View {
        Picker("Day", selection: dayBinding) {
            ForEach(daysInCurrentMonth, id: \.self) { day in
                Text("\(day)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.appText)
                    .tag(day)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
    }
    
    private var monthPicker: some View {
        Picker("Month", selection: monthBinding) {
            ForEach(allowedMonths, id: \.self) { month in
                Text(monthName(month))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.appText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .tag(month)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
    }
    
    private var yearPicker: some View {
        Picker("Year", selection: yearBinding) {
            ForEach(Array(yearRange), id: \.self) { year in
                Text(String(format: "%d", year))
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.appText)
                    .tag(year)
            }
        }
        .pickerStyle(.wheel)
        .labelsHidden()
    }
    
    private var footerButtons: some View {
        HStack(spacing: 10) {
            chromeButton(title: "accept".localized, action: onAccept)
            chromeButton(title: "cancel".localized) {
                selectedDate = originalDate
                onCancel()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func chromeButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.appText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(panelGradient)
                        .shadow(color: .black.opacity(0.22), radius: 5, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(gold, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Calendar bindings
    
    private var yearRange: ClosedRange<Int> {
        let end = calendar.component(.year, from: maxDate)
        let start = end - 120
        return start...end
    }
    
    private var allowedMonths: [Int] {
        let y = calendar.component(.year, from: selection)
        let cap = calendar.component(.year, from: maxDate)
        if y < cap { return Array(1...12) }
        let maxM = calendar.component(.month, from: maxDate)
        return Array(1...maxM)
    }
    
    private var daysInCurrentMonth: [Int] {
        let y = calendar.component(.year, from: selection)
        let m = calendar.component(.month, from: selection)
        let count = daysInMonth(year: y, month: m)
        let maxDay = min(count, maxAllowedDay(year: y, month: m))
        return Array(1...max(1, maxDay))
    }
    
    private func monthName(_ month: Int) -> String {
        guard month >= 1, month <= 12 else { return "" }
        return monthSymbols[month - 1]
    }
    
    private func maxAllowedMonth(forYear year: Int) -> Int {
        let capY = calendar.component(.year, from: maxDate)
        if year < capY { return 12 }
        return calendar.component(.month, from: maxDate)
    }
    
    private func daysInMonth(year: Int, month: Int) -> Int {
        guard let anchor = firstOfMonth(year: year, month: month),
              let range = calendar.range(of: .day, in: .month, for: anchor) else {
            return 28
        }
        return range.count
    }
    
    private func maxAllowedDay(year: Int, month: Int) -> Int {
        let dim = daysInMonth(year: year, month: month)
        let capY = calendar.component(.year, from: maxDate)
        let capM = calendar.component(.month, from: maxDate)
        let capD = calendar.component(.day, from: maxDate)
        if year < capY || (year == capY && month < capM) { return dim }
        if year == capY && month == capM { return min(dim, capD) }
        return dim
    }
    
    private func firstOfMonth(year: Int, month: Int) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: 1))
    }
    
    private func setSelection(year: Int, month: Int, day: Int) {
        let maxM = maxAllowedMonth(forYear: year)
        let m = min(month, maxM)
        let maxD = maxAllowedDay(year: year, month: m)
        let d = min(day, maxD)
        if let date = calendar.date(from: DateComponents(year: year, month: m, day: d)) {
            updateSelectedDate(date)
        }
    }
    
    private var yearBinding: Binding<Int> {
        Binding(
            get: { calendar.component(.year, from: selection) },
            set: { setSelection(year: $0, month: calendar.component(.month, from: selection), day: calendar.component(.day, from: selection)) }
        )
    }
    
    private var monthBinding: Binding<Int> {
        Binding(
            get: { calendar.component(.month, from: selection) },
            set: { setSelection(year: calendar.component(.year, from: selection), month: $0, day: calendar.component(.day, from: selection)) }
        )
    }
    
    private var dayBinding: Binding<Int> {
        Binding(
            get: { calendar.component(.day, from: selection) },
            set: { setSelection(year: calendar.component(.year, from: selection), month: calendar.component(.month, from: selection), day: $0) }
        )
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.5).ignoresSafeArea()
        DatePickerSheet(
            selectedDate: .constant("1995-06-15"),
            onAccept: {},
            onCancel: {}
        )
        .padding(20)
    }
}
