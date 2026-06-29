//
//  StoryPollEditorSheet.swift
//  Binbon
//

import SwiftUI

struct StoryPollEditorSheet: View {

    var initial: StoryPollPayload?
    var onCancel: () -> Void
    var onDone: (StoryPollPayload) -> Void

    @State private var question: String
    @State private var optionA: String
    @State private var optionB: String
    @State private var showResults: Bool

    init(
        initial: StoryPollPayload? = nil,
        onCancel: @escaping () -> Void,
        onDone: @escaping (StoryPollPayload) -> Void
    ) {
        self.initial = initial
        self.onCancel = onCancel
        self.onDone = onDone
        _question = State(initialValue: initial?.question ?? "")
        _optionA = State(initialValue: initial?.options.first ?? "Yes")
        _optionB = State(initialValue: initial?.options.dropFirst().first ?? "No")
        _showResults = State(initialValue: initial?.showResults ?? true)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Button("cancel".localized, action: onCancel).foregroundStyle(.white)
                    Spacer()
                    Text("story_poll_title".localized)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("done".localized, action: commit)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                VStack(spacing: 12) {
                    field("story_poll_question_placeholder".localized, text: $question)
                    field("story_poll_option_a".localized, text: $optionA)
                    field("story_poll_option_b".localized, text: $optionB)

                    Toggle("story_poll_show_results".localized, isOn: $showResults)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }

    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(14)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
    }

    private func commit() {
        let q = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = optionA.trimmingCharacters(in: .whitespacesAndNewlines)
        let b = optionB.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !a.isEmpty, !b.isEmpty else { return }
        onDone(StoryPollPayload(
            question: q,
            options: [a, b],
            percents: [65, 35],
            showResults: showResults
        ))
    }
}
