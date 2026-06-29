//
//  AddPersonSheetView.swift
//  Binbon
//
//  Created by 𝓚𝓱𝓪𝓵𝓮𝓭 𝓗𝓾𝓢𝓲𝓮𝓮𝓷 on 23/06/2026.
//

import SwiftUI

struct AddPersonSheetView: View {

    var excludedContactIDs: Set<UUID> = []
    var onAddParticipant: (MessageConversation) -> Void = { _ in }

    @State private var searchText = ""
    @State private var selectedContactID: UUID?
    @State private var addedContactIDs: Set<UUID> = []

    private var filteredContacts: [MessageConversation] {
        let available = MessageConversation.samples.filter { !excludedContactIDs.contains($0.id) }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return available }
        return available.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 16) {
            searchField
                .padding(.horizontal, 16)
                .padding(.top, 20)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(filteredContacts) { contact in
                        AddPersonContactRow(
                            contact: contact,
                            isSelected: selectedContactID == contact.id,
                            isAdded: addedContactIDs.contains(contact.id),
                            onSelect: { selectedContactID = contact.id },
                            onAdd: { addContact(contact) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppColor.voiceCallAddPersonSheetGradient.ignoresSafeArea())
        .localizedLayout()
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            TextField(
                "",
                text: $searchText,
                prompt: Text("messages_search_placeholder".localized)
                    .foregroundStyle(.white.opacity(0.72))
            )
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.95), lineWidth: 1)
        )
    }

    private func addContact(_ contact: MessageConversation) {
        guard !addedContactIDs.contains(contact.id) else { return }
        selectedContactID = contact.id
        addedContactIDs.insert(contact.id)
        onAddParticipant(contact)
    }
}

// MARK: - Contact row

private struct AddPersonContactRow: View {

    let contact: MessageConversation
    let isSelected: Bool
    let isAdded: Bool
    let onSelect: () -> Void
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ImageView(contact.avatarURL, placeholder: Image(systemName: "person.fill"))
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1))

            Text(contact.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onAdd) {
                Image(systemName: isAdded ? "checkmark" : "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("voice_call_add_contact".localizedFormat(contact.name))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColor.verificationGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isSelected ? AppColor.voiceCallAddPersonSelectionStroke : AppColor.gold,
                    lineWidth: isSelected ? 2 : 1.5
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onTapGesture(perform: onSelect)
    }
}

#Preview {
    AddPersonSheetView()
        .presentationDetents([.fraction(0.68)])
}
