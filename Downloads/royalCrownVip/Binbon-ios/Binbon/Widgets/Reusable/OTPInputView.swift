//
//  OTPInputView.swift
//  Binbon
//
//  Created by Salah Khaled on 19/04/2026.
//


import SwiftUI

struct OTPInputView: View {
    @Binding var code: String
    private let length: Int = 6
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            hiddenInput
            otpBoxesRow
        }
        .onTapGesture { isFocused = true }
    }

    private var hiddenInput: some View {
        TextField("", text: $code)
            .keyboardType(.numberPad)
            .focused($isFocused)
            .opacity(0.01)
            .frame(width: 1, height: 1)
            .onChange(of: code) { _, newValue in
                let filtered = newValue.filter(\.isNumber)
                if filtered.count > length {
                    code = String(filtered.prefix(length))
                } else if filtered != newValue {
                    code = filtered
                }
            }
    }

    private var otpBoxesRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<length, id: \.self) { index in
                OTPBox(
                    character: characterAt(index: index),
                    isActive: isFocused && index == code.count
                )
            }
        }
    }

    private func characterAt(index: Int) -> Character? {
        guard index < code.count else { return nil }
        return code[code.index(code.startIndex, offsetBy: index)]
    }
}

private struct OTPBox: View {
    let character: Character?
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appText.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isActive ? Color(hex: "E97840") : Color.appText.opacity(0.3), lineWidth: 1.5)
                )
                .frame(width: 46, height: 52)
            if let character {
                Text(String(character))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(white: 0.15))
            }
        }
    }
}
