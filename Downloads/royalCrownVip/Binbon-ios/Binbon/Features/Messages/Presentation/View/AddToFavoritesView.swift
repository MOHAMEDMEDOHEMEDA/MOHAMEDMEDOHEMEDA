//
//  AddToFavoritesView.swift
//  Binbon
//
//  The "add to favourites" picker reached from a conversation's long-press menu:
//  a Send button, a search field, and the conversation list with a green
//  multi-select toggle per row. Tapping Send hands the chosen rows back and the
//  caller shows a success toast. Mock-backed during the UI-only phase.
//

import SwiftUI

struct AddToFavoritesView: View {

    let candidates: [MessageConversation]
    let initialSelection: Set<UUID>
    /// Title shown above the list. Defaults to the favourites copy.
    var titleKey: String = "messages_add_fav_title"
    /// Confirm-button label. Defaults to "Send".
    var actionKey: String = "messages_send"
    let onSend: ([MessageConversation]) -> Void
    let onClose: () -> Void

    @ObservedObject private var theme = ThemeManager.shared
    @State private var selected: Set<UUID>
    @State private var searchText = ""

    init(candidates: [MessageConversation],
         initialSelection: Set<UUID>,
         titleKey: String = "messages_add_fav_title",
         actionKey: String = "messages_send",
         onSend: @escaping ([MessageConversation]) -> Void,
         onClose: @escaping () -> Void) {
        self.candidates = candidates
        self.initialSelection = initialSelection
        self.titleKey = titleKey
        self.actionKey = actionKey
        self.onSend = onSend
        self.onClose = onClose
        _selected = State(initialValue: initialSelection)
    }

    private var filtered: [MessageConversation] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return candidates }
        return candidates.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchField
                .padding(.horizontal, 16)
                .padding(.top, 4)

            Text(titleKey.localized)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.appText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

            list
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appBackground()
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(theme.preferredColorScheme)
    }

    // MARK: - Header (Send + dismiss)

    private var header: some View {
        ZStack {
            Button {
                onSend(candidates.filter { selected.contains($0.id) })
            } label: {
                Text(actionKey.localized)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.appText)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppColor.buttonGradient))
                    .overlay(Capsule().stroke(AppColor.gold, lineWidth: 2))
            }
            .buttonStyle(.plain)

            HStack {
                Button { onClose() } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.appText)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.appText.opacity(0.8))
            TextField("", text: $searchText, prompt:
                        Text("messages_search_placeholder".localized)
                .foregroundColor(.appText.opacity(0.7)))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.appText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.12)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.white, lineWidth: 3))
    }

    // MARK: - List

    private var list: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(filtered) { conversation in
                    MessageConversationRow(
                        conversation: conversation,
                        accessory: .selection(isOn: selected.contains(conversation.id)),
                        onCall: { toggle(conversation) },
                        onVideo: { toggle(conversation) }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { toggle(conversation) }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggle(_ conversation: MessageConversation) {
        if selected.contains(conversation.id) {
            selected.remove(conversation.id)
        } else {
            selected.insert(conversation.id)
        }
    }
}
