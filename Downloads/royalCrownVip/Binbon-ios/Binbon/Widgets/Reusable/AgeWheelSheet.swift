//
//  AgeWheelSheet.swift
//  Binbon
//
//  Created by Ramez Hamdy on 09/06/2026.
//

import SwiftUI

/// A compact bottom sheet with a single wheel picker for selecting an integer
/// age (or any bounded integer). Confirms with a "Done" button. Theme-aware.
struct AgeWheelSheet: View {

    @Binding var age: Int?
    let range: [Int]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Picker("age".localized, selection: Binding(
                get: { age ?? range.first ?? 18 },
                set: { age = $0 }
            )) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.appText)
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()

            AppButton(title: "done".localized) {
                if age == nil { age = range.first }
                dismiss()
            }
        }
        .padding(20)
        .appBackground()
        .presentationDetents([.height(320)])
    }
}

#Preview {
    AgeWheelSheet(age: .constant(25), range: Array(18...80))
}
