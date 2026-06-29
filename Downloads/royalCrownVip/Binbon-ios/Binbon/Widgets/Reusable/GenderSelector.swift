//
//  GenderSelector.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//

import SwiftUI

struct GenderSelector: View {
    @Binding var selectedGender: GenderType

    var body: some View {
        HStack(spacing: 150) {
            ForEach(GenderType.allCases, id: \.self) { gender in
                GenderOption(
                    gender: gender,
                    isSelected: selectedGender == gender,
                    onSelect: { selectedGender = gender }
                )
            }
        }
    }
}

private struct GenderOption: View {
    let gender: GenderType
    let isSelected: Bool
    let onSelect: () -> Void

    private var avatarColor: Color {
        gender == .female ? Color(hex: "D06090") : Color(hex: "5060D0")
    }

    private var symbolName: String {
        gender == .male ? "Male" : "Female"
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Circle()
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(symbolName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.appText)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? .green : .clear,
                                lineWidth: 3
                            )
                    )
                    .shadow(color: isSelected ? .green.opacity(0.5) : .clear, radius: 6)

                Text(gender.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.appText)
            }
        }
    }
}
