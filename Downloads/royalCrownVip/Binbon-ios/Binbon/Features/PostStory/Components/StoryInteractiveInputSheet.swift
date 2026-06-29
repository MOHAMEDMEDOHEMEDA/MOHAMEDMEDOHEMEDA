//
//  StoryInteractiveInputSheet.swift
//  Binbon
//
//  Created by ahmedkamal on 18/06/2026.
//

import SwiftUI

struct StoryInteractiveInputSheet: View {
    let title: String
    let placeholder: String
    var initialText: String = ""
    var onCancel: () -> Void
    var onDone: (String) -> Void

    @State private var text: String
    @FocusState private var focused: Bool

    init(
        title: String,
        placeholder: String,
        initialText: String = "",
        onCancel: @escaping () -> Void,
        onDone: @escaping (String) -> Void
    ) {
        self.title = title
        self.placeholder = placeholder
        self.initialText = initialText
        self.onCancel = onCancel
        self.onDone = onDone
        _text = State(initialValue: initialText)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture { commit() }

            VStack(spacing: 20) {
                HStack {
                    Button("cancel".localized, action: onCancel)
                        .foregroundStyle(.white)
                    Spacer()
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("done".localized, action: commit)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                TextField(placeholder, text: $text)
                    .focused($focused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)

                Spacer()
            }
        }
        .onAppear { focused = true }
    }

    private func commit() {
        onDone(text)
    }
}
