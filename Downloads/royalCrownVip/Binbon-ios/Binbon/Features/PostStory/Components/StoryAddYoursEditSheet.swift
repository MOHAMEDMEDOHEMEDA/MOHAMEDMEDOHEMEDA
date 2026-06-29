//
//  StoryAddYoursEditSheet.swift
//  Binbon
//

import SwiftUI

struct StoryAddYoursMenuBar: View {

    var onEdit: () -> Void
    var onSetPercent: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            menuRow("pencil", "story_add_yours_edit".localized, action: onEdit)
            Divider().overlay(.white.opacity(0.15))
            menuRow("percent", "story_add_yours_set_percent".localized, action: onSetPercent)
        }
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.88), in: RoundedRectangle(cornerRadius: 12))
    }

    private func menuRow(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title)
                Spacer()
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

struct StoryAddYoursMenuPopup: View {

    var onEdit: () -> Void
    var onSetPercent: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            StoryAddYoursMenuBar(onEdit: onEdit, onSetPercent: onSetPercent)
                .padding(.horizontal, 48)
                .padding(.top, 140)
        }
    }
}

struct StoryAddYoursPromptSheet: View {

    var payload: StoryAddYoursPayload
    var onCancel: () -> Void
    var onDone: (StoryAddYoursPayload) -> Void

    @State private var prompt: String
    @State private var emoji: String

    init(
        payload: StoryAddYoursPayload,
        onCancel: @escaping () -> Void,
        onDone: @escaping (StoryAddYoursPayload) -> Void
    ) {
        self.payload = payload
        self.onCancel = onCancel
        self.onDone = onDone
        _prompt = State(initialValue: payload.prompt)
        _emoji = State(initialValue: payload.emoji)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Button("cancel".localized, action: onCancel).foregroundStyle(.white)
                    Spacer()
                    Text("story_add_yours_edit".localized)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("done".localized, action: commit)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                TextField("story_add_yours_placeholder".localized, text: $prompt)
                    .padding(14)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)

                TextField("story_add_yours_emoji".localized, text: $emoji)
                    .padding(14)
                    .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)

                Spacer()
            }
        }
    }

    private func commit() {
        let cleanPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanPrompt.isEmpty, !cleanEmoji.isEmpty else { return }
        onDone(StoryAddYoursPayload(
            prompt: cleanPrompt,
            emoji: cleanEmoji,
            sliderPercent: payload.sliderPercent
        ))
    }
}

struct StoryAddYoursPercentSheet: View {

    var payload: StoryAddYoursPayload
    var onCancel: () -> Void
    var onChange: (StoryAddYoursPayload) -> Void = { _ in }
    var onDone: (StoryAddYoursPayload) -> Void

    @State private var sliderPercent: Double

    init(
        payload: StoryAddYoursPayload,
        onCancel: @escaping () -> Void,
        onChange: @escaping (StoryAddYoursPayload) -> Void = { _ in },
        onDone: @escaping (StoryAddYoursPayload) -> Void
    ) {
        self.payload = payload
        self.onCancel = onCancel
        self.onChange = onChange
        self.onDone = onDone
        _sliderPercent = State(initialValue: Double(payload.sliderPercent))
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    Button("cancel".localized, action: onCancel).foregroundStyle(.white)
                    Spacer()
                    Text("story_add_yours_set_percent".localized)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("done".localized, action: commit)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                HStack(spacing: 12) {
                    Text(payload.emoji).font(.system(size: 32))
                    Slider(value: $sliderPercent, in: 0...1)
                        .onChange(of: sliderPercent) { _, value in
                            onChange(currentPayload(value))
                        }
                    Text("\(Int(sliderPercent * 100))%")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private func currentPayload(_ percent: Double? = nil) -> StoryAddYoursPayload {
        StoryAddYoursPayload(
            prompt: payload.prompt,
            emoji: payload.emoji,
            sliderPercent: CGFloat(percent ?? sliderPercent)
        )
    }

    private func commit() {
        onDone(currentPayload())
    }
}
